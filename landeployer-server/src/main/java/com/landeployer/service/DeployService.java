package com.landeployer.service;

import com.landeployer.dto.MissingPackage;
import com.landeployer.entity.DeployRole;
import com.landeployer.entity.DeployTask;
import com.landeployer.entity.Host;
import com.landeployer.repository.DeployTaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 部署服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeployService {
    
    private final DeployTaskRepository deployTaskRepository;
    private final HostService hostService;
    private final DeployRoleService deployRoleService;
    private final SSHService sshService;
    
    @Value("${app.remote-path:/opt/offline}")
    private String remotePath;
    
    /**
     * 创建部署任务
     */
    @Transactional
    public DeployTask createTask(String taskName, Long hostId, List<String> roleCodes, String createBy) {
        Host host = hostService.findById(hostId);
        if (host == null) {
            throw new RuntimeException("主机不存在");
        }
        
        DeployTask task = new DeployTask();
        task.setTaskName(taskName);
        task.setHostId(hostId);
        task.setHostName(host.getName());
        task.setRoles(String.join(",", roleCodes));
        task.setStatus("pending");
        task.setProgress(0);
        task.setCreateBy(createBy);
        
        return deployTaskRepository.save(task);
    }
    
    /**
     * 检查缺失的包
     */
    public List<MissingPackage> checkMissingPackages(Long hostId, List<String> roleCodes) {
        Host host = hostService.findById(hostId);
        if (host == null) {
            throw new RuntimeException("主机不存在");
        }
        
        List<MissingPackage> missingList = new ArrayList<>();
        
        for (String roleCode : roleCodes) {
            DeployRole role = deployRoleService.findByCode(roleCode);
            if (role == null) {
                continue;
            }
            
            String imageRemotePath = host.getRemotePath() + "/images/" + role.getTarName();
            String composeRemotePath = host.getRemotePath() + "/compose/" + role.getComposeName();
            
            try {
                // 检查镜像tar包
                boolean imageExists = sshService.checkFileExists(host, imageRemotePath);
                if (!imageExists) {
                    missingList.add(new MissingPackage(
                        roleCode, role.getName(), role.getTarName(), imageRemotePath, false
                    ));
                }
                
                // 检查compose文件
                boolean composeExists = sshService.checkFileExists(host, composeRemotePath);
                if (!composeExists) {
                    missingList.add(new MissingPackage(
                        roleCode, role.getName(), role.getComposeName(), composeRemotePath, false
                    ));
                }
                
            } catch (Exception e) {
                log.error("检查包失败: {}", e.getMessage(), e);
                missingList.add(new MissingPackage(
                    roleCode, role.getName(), role.getTarName(), imageRemotePath, false
                ));
            }
        }
        
        return missingList;
    }
    
    /**
     * 执行部署任务（异步）
     */
    @Async
    @Transactional
    public void executeTask(Long taskId) {
        DeployTask task = deployTaskRepository.findById(taskId).orElse(null);
        if (task == null) {
            log.error("任务不存在: {}", taskId);
            return;
        }
        
        Host host = hostService.findById(task.getHostId());
        if (host == null) {
            updateTaskFailed(task, "主机不存在");
            return;
        }
        
        // 更新任务状态
        task.setStatus("running");
        task.setStartTime(LocalDateTime.now());
        deployTaskRepository.save(task);
        
        StringBuilder logs = new StringBuilder();
        
        try {
            List<String> roleCodes = Arrays.asList(task.getRoles().split(","));
            int totalSteps = roleCodes.size() * 3; // 每个角色3步：上传、加载、启动
            int currentStep = 0;
            
            for (String roleCode : roleCodes) {
                DeployRole role = deployRoleService.findByCode(roleCode);
                if (role == null) {
                    continue;
                }
                
                logs.append("\n========== 开始部署 ").append(role.getName()).append(" ==========\n");
                
                // 1. 检查并加载镜像
                logs.append("1. 加载Docker镜像...\n");
                String loadCmd = String.format("cd %s && docker load -i images/%s", 
                        host.getRemotePath(), role.getTarName());
                String loadResult = sshService.executeCommand(host, loadCmd);
                logs.append(loadResult).append("\n");
                
                currentStep++;
                task.setProgress((int) ((currentStep * 100.0) / totalSteps));
                task.setLogs(logs.toString());
                deployTaskRepository.save(task);
                
                // 2. 启动容器
                logs.append("2. 启动容器...\n");
                String upCmd = String.format("cd %s && docker-compose -f compose/%s up -d", 
                        host.getRemotePath(), role.getComposeName());
                String upResult = sshService.executeCommand(host, upCmd);
                logs.append(upResult).append("\n");
                
                currentStep++;
                task.setProgress((int) ((currentStep * 100.0) / totalSteps));
                task.setLogs(logs.toString());
                deployTaskRepository.save(task);
                
                // 3. 验证状态
                logs.append("3. 验证容器状态...\n");
                String psCmd = "docker-compose -f " + host.getRemotePath() + "/compose/" 
                        + role.getComposeName() + " ps";
                String psResult = sshService.executeCommand(host, psCmd);
                logs.append(psResult).append("\n");
                
                currentStep++;
                task.setProgress((int) ((currentStep * 100.0) / totalSteps));
                task.setLogs(logs.toString());
                deployTaskRepository.save(task);
                
                logs.append("✓ ").append(role.getName()).append(" 部署完成\n\n");
            }
            
            // 任务完成
            task.setStatus("success");
            task.setProgress(100);
            task.setEndTime(LocalDateTime.now());
            task.setLogs(logs.toString());
            deployTaskRepository.save(task);
            
            log.info("部署任务完成: {}", taskId);
            
        } catch (Exception e) {
            log.error("部署任务失败: {}", e.getMessage(), e);
            updateTaskFailed(task, "部署失败: " + e.getMessage());
        }
    }
    
    private void updateTaskFailed(DeployTask task, String errorMsg) {
        task.setStatus("failed");
        task.setErrorMsg(errorMsg);
        task.setEndTime(LocalDateTime.now());
        deployTaskRepository.save(task);
    }
    
    /**
     * 查询所有任务
     */
    public List<DeployTask> findAll() {
        return deployTaskRepository.findAll();
    }
    
    /**
     * 根据主机ID查询任务
     */
    public List<DeployTask> findByHostId(Long hostId) {
        return deployTaskRepository.findByHostIdOrderByCreateTimeDesc(hostId);
    }
    
    /**
     * 根据ID查询任务
     */
    public DeployTask findById(Long id) {
        return deployTaskRepository.findById(id).orElse(null);
    }
}


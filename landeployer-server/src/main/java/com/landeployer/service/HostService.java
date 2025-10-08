package com.landeployer.service;

import com.landeployer.dto.HostTestResult;
import com.landeployer.entity.Host;
import com.landeployer.repository.HostRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 主机服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class HostService {
    
    private final HostRepository hostRepository;
    private final SSHService sshService;
    
    /**
     * 查询所有主机
     */
    public List<Host> findAll() {
        return hostRepository.findAll();
    }
    
    /**
     * 根据ID查询
     */
    public Host findById(Long id) {
        return hostRepository.findById(id).orElse(null);
    }
    
    /**
     * 保存主机
     */
    @Transactional
    public Host save(Host host) {
        return hostRepository.save(host);
    }
    
    /**
     * 删除主机
     */
    @Transactional
    public void delete(Long id) {
        hostRepository.deleteById(id);
    }
    
    /**
     * 测试主机连接
     */
    public HostTestResult testConnection(Host host) {
        long startTime = System.currentTimeMillis();
        HostTestResult result = new HostTestResult();
        
        try {
            boolean connected = sshService.testConnection(host);
            
            if (connected) {
                // 获取系统信息
                String osInfo = sshService.executeCommand(host, "uname -a");
                String dockerVersion = sshService.executeCommand(host, "docker --version");
                
                result.setSuccess(true);
                result.setMessage("连接成功");
                result.setOsInfo(osInfo != null ? osInfo.trim() : "未知");
                result.setDockerVersion(dockerVersion != null ? dockerVersion.trim() : "未安装");
                
                // 更新主机状态
                if (host.getId() != null) {
                    host.setStatus("online");
                    host.setLastConnectTime(LocalDateTime.now());
                    hostRepository.save(host);
                }
            } else {
                result.setSuccess(false);
                result.setMessage("连接失败");
                
                if (host.getId() != null) {
                    host.setStatus("offline");
                    hostRepository.save(host);
                }
            }
            
        } catch (Exception e) {
            log.error("主机连接测试失败: {}", e.getMessage(), e);
            result.setSuccess(false);
            result.setMessage("连接失败: " + e.getMessage());
            
            if (host.getId() != null) {
                host.setStatus("offline");
                hostRepository.save(host);
            }
        }
        
        result.setResponseTime(System.currentTimeMillis() - startTime);
        return result;
    }
    
    /**
     * 根据分组查询
     */
    public List<Host> findByGroup(String groupName) {
        return hostRepository.findByGroupName(groupName);
    }
}


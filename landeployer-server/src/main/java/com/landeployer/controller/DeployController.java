package com.landeployer.controller;

import com.landeployer.dto.MissingPackage;
import com.landeployer.dto.ResponseResult;
import com.landeployer.entity.DeployTask;
import com.landeployer.service.DeployService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 部署控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/deploy")
@RequiredArgsConstructor
public class DeployController {
    
    private final DeployService deployService;
    
    /**
     * 检查缺失的包
     */
    @PostMapping("/check")
    public ResponseResult<List<MissingPackage>> checkMissingPackages(@RequestBody Map<String, Object> params) {
        try {
            Long hostId = Long.valueOf(params.get("hostId").toString());
            @SuppressWarnings("unchecked")
            List<String> roleCodes = (List<String>) params.get("roleCodes");
            
            List<MissingPackage> missingList = deployService.checkMissingPackages(hostId, roleCodes);
            return ResponseResult.success(missingList);
        } catch (Exception e) {
            log.error("检查包失败", e);
            return ResponseResult.error("检查失败: " + e.getMessage());
        }
    }
    
    /**
     * 创建部署任务
     */
    @PostMapping("/task")
    public ResponseResult<DeployTask> createTask(@RequestBody Map<String, Object> params) {
        try {
            String taskName = params.get("taskName").toString();
            Long hostId = Long.valueOf(params.get("hostId").toString());
            @SuppressWarnings("unchecked")
            List<String> roleCodes = (List<String>) params.get("roleCodes");
            String createBy = params.getOrDefault("createBy", "admin").toString();
            
            DeployTask task = deployService.createTask(taskName, hostId, roleCodes, createBy);
            
            // 异步执行任务
            deployService.executeTask(task.getId());
            
            return ResponseResult.success("任务创建成功", task);
        } catch (Exception e) {
            log.error("创建任务失败", e);
            return ResponseResult.error("创建失败: " + e.getMessage());
        }
    }
    
    /**
     * 查询所有任务
     */
    @GetMapping("/tasks")
    public ResponseResult<List<DeployTask>> findAllTasks() {
        List<DeployTask> tasks = deployService.findAll();
        return ResponseResult.success(tasks);
    }
    
    /**
     * 根据主机ID查询任务
     */
    @GetMapping("/tasks/host/{hostId}")
    public ResponseResult<List<DeployTask>> findTasksByHost(@PathVariable Long hostId) {
        List<DeployTask> tasks = deployService.findByHostId(hostId);
        return ResponseResult.success(tasks);
    }
    
    /**
     * 根据ID查询任务
     */
    @GetMapping("/tasks/{id}")
    public ResponseResult<DeployTask> findTaskById(@PathVariable Long id) {
        DeployTask task = deployService.findById(id);
        if (task == null) {
            return ResponseResult.error("任务不存在");
        }
        return ResponseResult.success(task);
    }
}


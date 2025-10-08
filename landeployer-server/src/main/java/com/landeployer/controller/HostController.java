package com.landeployer.controller;

import com.landeployer.dto.HostTestResult;
import com.landeployer.dto.ResponseResult;
import com.landeployer.entity.Host;
import com.landeployer.service.HostService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

/**
 * 主机管理控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/hosts")
@RequiredArgsConstructor
public class HostController {
    
    private final HostService hostService;
    
    /**
     * 查询所有主机
     */
    @GetMapping
    public ResponseResult<List<Host>> findAll() {
        List<Host> hosts = hostService.findAll();
        return ResponseResult.success(hosts);
    }
    
    /**
     * 根据ID查询主机
     */
    @GetMapping("/{id}")
    public ResponseResult<Host> findById(@PathVariable Long id) {
        Host host = hostService.findById(id);
        if (host == null) {
            return ResponseResult.error("主机不存在");
        }
        return ResponseResult.success(host);
    }
    
    /**
     * 保存主机
     */
    @PostMapping
    public ResponseResult<Host> save(@Valid @RequestBody Host host) {
        try {
            Host saved = hostService.save(host);
            return ResponseResult.success("保存成功", saved);
        } catch (Exception e) {
            log.error("保存主机失败", e);
            return ResponseResult.error("保存失败: " + e.getMessage());
        }
    }
    
    /**
     * 更新主机
     */
    @PutMapping("/{id}")
    public ResponseResult<Host> update(@PathVariable Long id, @Valid @RequestBody Host host) {
        try {
            host.setId(id);
            Host updated = hostService.save(host);
            return ResponseResult.success("更新成功", updated);
        } catch (Exception e) {
            log.error("更新主机失败", e);
            return ResponseResult.error("更新失败: " + e.getMessage());
        }
    }
    
    /**
     * 删除主机
     */
    @DeleteMapping("/{id}")
    public ResponseResult<Void> delete(@PathVariable Long id) {
        try {
            hostService.delete(id);
            return ResponseResult.success("删除成功", null);
        } catch (Exception e) {
            log.error("删除主机失败", e);
            return ResponseResult.error("删除失败: " + e.getMessage());
        }
    }
    
    /**
     * 测试连接
     */
    @PostMapping("/test")
    public ResponseResult<HostTestResult> testConnection(@RequestBody Host host) {
        try {
            HostTestResult result = hostService.testConnection(host);
            return ResponseResult.success(result);
        } catch (Exception e) {
            log.error("测试连接失败", e);
            return ResponseResult.error("测试失败: " + e.getMessage());
        }
    }
    
    /**
     * 根据分组查询
     */
    @GetMapping("/group/{groupName}")
    public ResponseResult<List<Host>> findByGroup(@PathVariable String groupName) {
        List<Host> hosts = hostService.findByGroup(groupName);
        return ResponseResult.success(hosts);
    }
}


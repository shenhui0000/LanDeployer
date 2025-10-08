package com.landeployer.controller;

import com.landeployer.dto.ResponseResult;
import com.landeployer.entity.DeployRole;
import com.landeployer.service.DeployRoleService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 部署角色控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/roles")
@RequiredArgsConstructor
public class DeployRoleController {
    
    private final DeployRoleService deployRoleService;
    
    /**
     * 查询所有启用的角色
     */
    @GetMapping("/enabled")
    public ResponseResult<List<DeployRole>> findAllEnabled() {
        List<DeployRole> roles = deployRoleService.findAllEnabled();
        return ResponseResult.success(roles);
    }
    
    /**
     * 查询所有角色
     */
    @GetMapping
    public ResponseResult<List<DeployRole>> findAll() {
        List<DeployRole> roles = deployRoleService.findAll();
        return ResponseResult.success(roles);
    }
    
    /**
     * 根据code查询
     */
    @GetMapping("/code/{code}")
    public ResponseResult<DeployRole> findByCode(@PathVariable String code) {
        DeployRole role = deployRoleService.findByCode(code);
        if (role == null) {
            return ResponseResult.error("角色不存在");
        }
        return ResponseResult.success(role);
    }
    
    /**
     * 保存角色
     */
    @PostMapping
    public ResponseResult<DeployRole> save(@RequestBody DeployRole role) {
        try {
            DeployRole saved = deployRoleService.save(role);
            return ResponseResult.success("保存成功", saved);
        } catch (Exception e) {
            log.error("保存角色失败", e);
            return ResponseResult.error("保存失败: " + e.getMessage());
        }
    }
    
    /**
     * 删除角色
     */
    @DeleteMapping("/{id}")
    public ResponseResult<Void> delete(@PathVariable Long id) {
        try {
            deployRoleService.delete(id);
            return ResponseResult.success("删除成功", null);
        } catch (Exception e) {
            log.error("删除角色失败", e);
            return ResponseResult.error("删除失败: " + e.getMessage());
        }
    }
}


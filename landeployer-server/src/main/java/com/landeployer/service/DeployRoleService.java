package com.landeployer.service;

import com.landeployer.entity.DeployRole;
import com.landeployer.repository.DeployRoleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;
import java.util.Arrays;
import java.util.List;

/**
 * 部署角色服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DeployRoleService {
    
    private final DeployRoleRepository deployRoleRepository;
    
    /**
     * 初始化默认角色
     */
    @PostConstruct
    @Transactional
    public void initDefaultRoles() {
        long count = deployRoleRepository.count();
        if (count > 0) {
            return;
        }
        
        log.info("初始化默认部署角色...");
        
        List<DeployRole> roles = Arrays.asList(
            createRole("openresty", "OpenResty", "openresty.tar", "openresty.yml", 
                    "80,443,9145", null, "高性能Web平台", "🌐", 1),
            createRole("redis", "Redis", "redis.tar", "redis.yml", 
                    "6379,9121", null, "缓存数据库", "🔴", 2),
            createRole("mysql", "MySQL", "mysql.tar", "mysql.yml", 
                    "3306,9104", null, "关系型数据库", "🐬", 3),
            createRole("prometheus", "Prometheus", "prometheus.tar", "prometheus.yml", 
                    "9090", null, "监控系统", "📊", 4),
            createRole("grafana", "Grafana", "grafana.tar", "grafana.yml", 
                    "3000", "prometheus", "可视化面板", "📈", 5),
            createRole("node-exporter", "Node Exporter", "node-exporter.tar", "node-exporter.yml", 
                    "9100", null, "节点监控", "💻", 6),
            createRole("springboot", "SpringBoot", "springboot.tar", "springboot.yml", 
                    "8080,8081", null, "Java应用", "☕", 7)
        );
        
        deployRoleRepository.saveAll(roles);
        log.info("默认角色初始化完成");
    }
    
    private DeployRole createRole(String code, String name, String tarName, String composeName,
                                  String ports, String dependencies, String description, 
                                  String icon, int sortOrder) {
        DeployRole role = new DeployRole();
        role.setCode(code);
        role.setName(name);
        role.setTarName(tarName);
        role.setComposeName(composeName);
        role.setPorts(ports);
        role.setDependencies(dependencies);
        role.setDescription(description);
        role.setIcon(icon);
        role.setSortOrder(sortOrder);
        role.setEnabled(true);
        return role;
    }
    
    /**
     * 查询所有启用的角色
     */
    public List<DeployRole> findAllEnabled() {
        return deployRoleRepository.findByEnabledOrderBySortOrder(true);
    }
    
    /**
     * 查询所有角色
     */
    public List<DeployRole> findAll() {
        return deployRoleRepository.findAll();
    }
    
    /**
     * 根据code查询
     */
    public DeployRole findByCode(String code) {
        return deployRoleRepository.findByCode(code);
    }
    
    /**
     * 保存角色
     */
    @Transactional
    public DeployRole save(DeployRole role) {
        return deployRoleRepository.save(role);
    }
    
    /**
     * 删除角色
     */
    @Transactional
    public void delete(Long id) {
        deployRoleRepository.deleteById(id);
    }
}


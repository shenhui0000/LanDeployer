package com.landeployer.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 部署角色（如OpenResty、MySQL、Redis等）
 */
@Data
@Entity
@Table(name = "deploy_role")
public class DeployRole {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 角色编码
     */
    @Column(nullable = false, unique = true, length = 50)
    private String code;
    
    /**
     * 角色名称
     */
    @Column(nullable = false, length = 100)
    private String name;
    
    /**
     * 镜像tar包名称
     */
    @Column(nullable = false, length = 200)
    private String tarName;
    
    /**
     * docker-compose文件名
     */
    @Column(nullable = false, length = 200)
    private String composeName;
    
    /**
     * 所需端口列表（逗号分隔）
     */
    @Column(length = 500)
    private String ports;
    
    /**
     * 依赖的角色（逗号分隔的code）
     */
    @Column(length = 500)
    private String dependencies;
    
    /**
     * 描述
     */
    @Column(length = 500)
    private String description;
    
    /**
     * 图标
     */
    @Column(length = 200)
    private String icon;
    
    /**
     * 排序
     */
    @Column(nullable = false)
    private Integer sortOrder = 0;
    
    /**
     * 是否启用
     */
    @Column(nullable = false)
    private Boolean enabled = true;
    
    /**
     * 创建时间
     */
    @Column(nullable = false, updatable = false)
    private LocalDateTime createTime;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
}


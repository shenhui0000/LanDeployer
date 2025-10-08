package com.landeployer.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 资源包（镜像tar包、脚本等）
 */
@Data
@Entity
@Table(name = "resource_package")
public class ResourcePackage {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 包名称
     */
    @Column(nullable = false, length = 200)
    private String name;
    
    /**
     * 包类型: image, script, compose, config
     */
    @Column(nullable = false, length = 20)
    private String type;
    
    /**
     * 关联角色code
     */
    @Column(length = 50)
    private String roleCode;
    
    /**
     * 文件路径（本地存储）
     */
    @Column(nullable = false, length = 500)
    private String filePath;
    
    /**
     * 文件大小（字节）
     */
    @Column(nullable = false)
    private Long fileSize;
    
    /**
     * MD5值
     */
    @Column(nullable = false, length = 64)
    private String md5;
    
    /**
     * 版本号
     */
    @Column(length = 50)
    private String version;
    
    /**
     * 描述
     */
    @Column(length = 500)
    private String description;
    
    /**
     * 创建时间
     */
    @Column(nullable = false, updatable = false)
    private LocalDateTime createTime;
    
    /**
     * 上传人
     */
    @Column(length = 50)
    private String uploadBy;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
}


package com.landeployer.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 服务器主机实体
 */
@Data
@Entity
@Table(name = "host")
public class Host {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 主机名称
     */
    @Column(nullable = false, length = 100)
    private String name;
    
    /**
     * IP地址
     */
    @Column(nullable = false, length = 50)
    private String ip;
    
    /**
     * SSH端口
     */
    @Column(nullable = false)
    private Integer port = 22;
    
    /**
     * 用户名
     */
    @Column(nullable = false, length = 50)
    private String username;
    
    /**
     * 认证方式: password, privateKey
     */
    @Column(nullable = false, length = 20)
    private String authType;
    
    /**
     * 密码（加密存储）
     */
    @Column(length = 500)
    private String password;
    
    /**
     * 私钥内容
     */
    @Column(columnDefinition = "TEXT")
    private String privateKey;
    
    /**
     * 私钥密码
     */
    @Column(length = 500)
    private String privateKeyPassword;
    
    /**
     * 远程部署路径
     */
    @Column(nullable = false, length = 200)
    private String remotePath = "/opt/offline";
    
    /**
     * 分组
     */
    @Column(length = 100)
    private String groupName;
    
    /**
     * 描述
     */
    @Column(length = 500)
    private String description;
    
    /**
     * 连接状态: online, offline, unknown
     */
    @Column(length = 20)
    private String status = "unknown";
    
    /**
     * 最后连接时间
     */
    private LocalDateTime lastConnectTime;
    
    /**
     * 创建时间
     */
    @Column(nullable = false, updatable = false)
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    @Column(nullable = false)
    private LocalDateTime updateTime;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
        updateTime = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updateTime = LocalDateTime.now();
    }
}


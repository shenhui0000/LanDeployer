package com.landeployer.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 部署任务
 */
@Data
@Entity
@Table(name = "deploy_task")
public class DeployTask {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    /**
     * 任务名称
     */
    @Column(nullable = false, length = 200)
    private String taskName;
    
    /**
     * 主机ID
     */
    @Column(nullable = false)
    private Long hostId;
    
    /**
     * 主机名称（冗余字段，方便查询）
     */
    @Column(length = 100)
    private String hostName;
    
    /**
     * 部署角色列表（逗号分隔的code）
     */
    @Column(nullable = false, length = 500)
    private String roles;
    
    /**
     * 任务状态: pending, running, success, failed, cancelled
     */
    @Column(nullable = false, length = 20)
    private String status = "pending";
    
    /**
     * 执行进度（0-100）
     */
    @Column(nullable = false)
    private Integer progress = 0;
    
    /**
     * 执行日志
     */
    @Column(columnDefinition = "TEXT")
    private String logs;
    
    /**
     * 错误信息
     */
    @Column(columnDefinition = "TEXT")
    private String errorMsg;
    
    /**
     * 开始时间
     */
    private LocalDateTime startTime;
    
    /**
     * 结束时间
     */
    private LocalDateTime endTime;
    
    /**
     * 创建时间
     */
    @Column(nullable = false, updatable = false)
    private LocalDateTime createTime;
    
    /**
     * 创建人
     */
    @Column(length = 50)
    private String createBy;
    
    @PrePersist
    protected void onCreate() {
        createTime = LocalDateTime.now();
    }
}


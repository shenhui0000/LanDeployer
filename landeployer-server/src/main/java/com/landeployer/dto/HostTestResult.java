package com.landeployer.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 主机连接测试结果
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HostTestResult {
    
    /**
     * 是否成功
     */
    private Boolean success;
    
    /**
     * 消息
     */
    private String message;
    
    /**
     * 操作系统信息
     */
    private String osInfo;
    
    /**
     * Docker版本
     */
    private String dockerVersion;
    
    /**
     * 响应时间（毫秒）
     */
    private Long responseTime;
}


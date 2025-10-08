package com.landeployer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * LanDeployer 主应用
 * 离线内网一键部署工具
 */
@SpringBootApplication
@EnableAsync
public class LanDeployerApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(LanDeployerApplication.class, args);
        System.out.println("\n====================================");
        System.out.println("LanDeployer 启动成功！");
        System.out.println("访问地址: http://localhost:8080");
        System.out.println("默认账号: admin / admin123");
        System.out.println("====================================\n");
    }
}


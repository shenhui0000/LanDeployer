package com.landeployer.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 缺失的包信息
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MissingPackage {
    
    /**
     * 角色code
     */
    private String roleCode;
    
    /**
     * 角色名称
     */
    private String roleName;
    
    /**
     * 包名称
     */
    private String packageName;
    
    /**
     * 远程路径
     */
    private String remotePath;
    
    /**
     * 是否存在
     */
    private Boolean exists;
}


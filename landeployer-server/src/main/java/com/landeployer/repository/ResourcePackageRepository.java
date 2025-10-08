package com.landeployer.repository;

import com.landeployer.entity.ResourcePackage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 资源包Repository
 */
@Repository
public interface ResourcePackageRepository extends JpaRepository<ResourcePackage, Long> {
    
    /**
     * 根据名称查询
     */
    ResourcePackage findByName(String name);
    
    /**
     * 根据类型查询
     */
    List<ResourcePackage> findByType(String type);
    
    /**
     * 根据角色code查询
     */
    List<ResourcePackage> findByRoleCode(String roleCode);
    
    /**
     * 根据MD5查询
     */
    ResourcePackage findByMd5(String md5);
}


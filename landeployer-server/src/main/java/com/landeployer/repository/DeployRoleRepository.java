package com.landeployer.repository;

import com.landeployer.entity.DeployRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 部署角色Repository
 */
@Repository
public interface DeployRoleRepository extends JpaRepository<DeployRole, Long> {
    
    /**
     * 根据code查询
     */
    DeployRole findByCode(String code);
    
    /**
     * 查询启用的角色
     */
    List<DeployRole> findByEnabledOrderBySortOrder(Boolean enabled);
    
    /**
     * 根据code列表查询
     */
    List<DeployRole> findByCodeIn(List<String> codes);
}


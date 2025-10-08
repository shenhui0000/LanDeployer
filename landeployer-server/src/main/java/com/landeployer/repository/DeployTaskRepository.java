package com.landeployer.repository;

import com.landeployer.entity.DeployTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 部署任务Repository
 */
@Repository
public interface DeployTaskRepository extends JpaRepository<DeployTask, Long> {
    
    /**
     * 根据主机ID查询
     */
    List<DeployTask> findByHostIdOrderByCreateTimeDesc(Long hostId);
    
    /**
     * 根据状态查询
     */
    List<DeployTask> findByStatusOrderByCreateTimeDesc(String status);
}


package com.landeployer.repository;

import com.landeployer.entity.Host;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 主机Repository
 */
@Repository
public interface HostRepository extends JpaRepository<Host, Long> {
    
    /**
     * 根据IP和端口查询
     */
    Host findByIpAndPort(String ip, Integer port);
    
    /**
     * 根据分组查询
     */
    List<Host> findByGroupName(String groupName);
    
    /**
     * 根据状态查询
     */
    List<Host> findByStatus(String status);
}


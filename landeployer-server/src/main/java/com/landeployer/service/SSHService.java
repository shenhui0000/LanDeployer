package com.landeployer.service;

import com.jcraft.jsch.*;
import com.landeployer.entity.Host;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.Properties;

/**
 * SSH服务
 */
@Slf4j
@Service
public class SSHService {
    
    @Value("${app.ssh-timeout:30000}")
    private Integer sshTimeout;
    
    /**
     * 创建SSH连接
     */
    public Session createSession(Host host) throws JSchException {
        JSch jsch = new JSch();
        
        Session session = jsch.getSession(host.getUsername(), host.getIp(), host.getPort());
        
        // 认证方式
        if ("password".equals(host.getAuthType())) {
            session.setPassword(host.getPassword());
        } else if ("privateKey".equals(host.getAuthType())) {
            if (host.getPrivateKeyPassword() != null && !host.getPrivateKeyPassword().isEmpty()) {
                jsch.addIdentity("key", host.getPrivateKey().getBytes(), 
                        null, host.getPrivateKeyPassword().getBytes());
            } else {
                jsch.addIdentity("key", host.getPrivateKey().getBytes(), null, null);
            }
        }
        
        // 配置
        Properties config = new Properties();
        config.put("StrictHostKeyChecking", "no");
        session.setConfig(config);
        session.setTimeout(sshTimeout);
        
        return session;
    }
    
    /**
     * 执行命令
     */
    public String executeCommand(Host host, String command) throws Exception {
        Session session = null;
        ChannelExec channel = null;
        
        try {
            session = createSession(host);
            session.connect();
            
            channel = (ChannelExec) session.openChannel("exec");
            channel.setCommand(command);
            
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            ByteArrayOutputStream errorStream = new ByteArrayOutputStream();
            
            channel.setOutputStream(outputStream);
            channel.setErrStream(errorStream);
            
            channel.connect();
            
            // 等待执行完成
            while (!channel.isClosed()) {
                Thread.sleep(100);
            }
            
            String output = outputStream.toString("UTF-8");
            String error = errorStream.toString("UTF-8");
            
            int exitStatus = channel.getExitStatus();
            
            if (exitStatus != 0) {
                log.warn("命令执行失败，退出码: {}, 错误: {}", exitStatus, error);
                return error;
            }
            
            return output;
            
        } finally {
            if (channel != null) {
                channel.disconnect();
            }
            if (session != null) {
                session.disconnect();
            }
        }
    }
    
    /**
     * 测试连接
     */
    public boolean testConnection(Host host) {
        Session session = null;
        try {
            session = createSession(host);
            session.connect();
            return session.isConnected();
        } catch (Exception e) {
            log.error("SSH连接测试失败: {}", e.getMessage());
            return false;
        } finally {
            if (session != null) {
                session.disconnect();
            }
        }
    }
    
    /**
     * 上传文件
     */
    public void uploadFile(Host host, String localFile, String remotePath) throws Exception {
        Session session = null;
        ChannelSftp channel = null;
        
        try {
            session = createSession(host);
            session.connect();
            
            channel = (ChannelSftp) session.openChannel("sftp");
            channel.connect();
            
            // 确保远程目录存在
            String remoteDir = remotePath.substring(0, remotePath.lastIndexOf('/'));
            createRemoteDir(channel, remoteDir);
            
            // 上传文件
            channel.put(localFile, remotePath);
            
            log.info("文件上传成功: {} -> {}", localFile, remotePath);
            
        } finally {
            if (channel != null) {
                channel.disconnect();
            }
            if (session != null) {
                session.disconnect();
            }
        }
    }
    
    /**
     * 创建远程目录
     */
    private void createRemoteDir(ChannelSftp channel, String path) throws SftpException {
        String[] dirs = path.split("/");
        String currentPath = "";
        
        for (String dir : dirs) {
            if (dir.isEmpty()) continue;
            
            currentPath += "/" + dir;
            try {
                channel.cd(currentPath);
            } catch (SftpException e) {
                channel.mkdir(currentPath);
                channel.cd(currentPath);
            }
        }
    }
    
    /**
     * 检查文件是否存在
     */
    public boolean checkFileExists(Host host, String remotePath) throws Exception {
        String command = "test -f " + remotePath + " && echo 'exists' || echo 'not exists'";
        String result = executeCommand(host, command);
        return result != null && result.trim().equals("exists");
    }
    
    /**
     * 检查目录是否存在
     */
    public boolean checkDirExists(Host host, String remotePath) throws Exception {
        String command = "test -d " + remotePath + " && echo 'exists' || echo 'not exists'";
        String result = executeCommand(host, command);
        return result != null && result.trim().equals("exists");
    }
}


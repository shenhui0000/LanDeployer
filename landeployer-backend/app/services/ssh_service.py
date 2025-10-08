"""
SSH服务
"""
import paramiko
from loguru import logger
from typing import Optional, Tuple
from app.config import settings

class SSHService:
    """SSH连接和命令执行服务"""
    
    @staticmethod
    def create_client(host_info: dict) -> paramiko.SSHClient:
        """创建SSH客户端"""
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        try:
            if host_info["auth_type"] == "password":
                client.connect(
                    hostname=host_info["ip"],
                    port=host_info["port"],
                    username=host_info["username"],
                    password=host_info["password"],
                    timeout=settings.SSH_TIMEOUT
                )
            elif host_info["auth_type"] == "privateKey":
                pkey = paramiko.RSAKey.from_private_key_file(
                    host_info["private_key"],
                    password=host_info.get("private_key_password")
                )
                client.connect(
                    hostname=host_info["ip"],
                    port=host_info["port"],
                    username=host_info["username"],
                    pkey=pkey,
                    timeout=settings.SSH_TIMEOUT
                )
            
            return client
        except Exception as e:
            logger.error(f"SSH连接失败: {e}")
            raise
    
    @staticmethod
    def execute_command(host_info: dict, command: str) -> Tuple[bool, str]:
        """
        执行SSH命令
        返回: (是否成功, 输出内容)
        """
        client = None
        try:
            client = SSHService.create_client(host_info)
            stdin, stdout, stderr = client.exec_command(command)
            
            exit_status = stdout.channel.recv_exit_status()
            output = stdout.read().decode('utf-8')
            error = stderr.read().decode('utf-8')
            
            if exit_status != 0:
                logger.warning(f"命令执行失败, 退出码: {exit_status}, 错误: {error}")
                return False, error if error else output
            
            return True, output
            
        except Exception as e:
            logger.error(f"执行命令失败: {e}")
            return False, str(e)
        finally:
            if client:
                client.close()
    
    @staticmethod
    def test_connection(host_info: dict) -> Tuple[bool, str, Optional[str], Optional[str]]:
        """
        测试连接
        返回: (是否成功, 消息, OS信息, Docker版本)
        """
        try:
            client = SSHService.create_client(host_info)
            
            # 获取系统信息
            stdin, stdout, stderr = client.exec_command("uname -a")
            os_info = stdout.read().decode('utf-8').strip()
            
            # 获取Docker版本
            stdin, stdout, stderr = client.exec_command("docker --version")
            docker_version = stdout.read().decode('utf-8').strip()
            
            client.close()
            
            return True, "连接成功", os_info, docker_version
            
        except Exception as e:
            logger.error(f"连接测试失败: {e}")
            return False, f"连接失败: {str(e)}", None, None
    
    @staticmethod
    def check_file_exists(host_info: dict, remote_path: str) -> bool:
        """检查文件是否存在"""
        command = f"test -f {remote_path} && echo 'exists' || echo 'not exists'"
        success, output = SSHService.execute_command(host_info, command)
        return success and output.strip() == 'exists'
    
    @staticmethod
    def check_dir_exists(host_info: dict, remote_path: str) -> bool:
        """检查目录是否存在"""
        command = f"test -d {remote_path} && echo 'exists' || echo 'not exists'"
        success, output = SSHService.execute_command(host_info, command)
        return success and output.strip() == 'exists'
    
    @staticmethod
    def upload_file(host_info: dict, local_path: str, remote_path: str) -> bool:
        """上传文件"""
        client = None
        try:
            client = SSHService.create_client(host_info)
            sftp = client.open_sftp()
            
            # 确保远程目录存在
            remote_dir = remote_path.rsplit('/', 1)[0]
            try:
                sftp.stat(remote_dir)
            except FileNotFoundError:
                # 创建目录
                SSHService.execute_command(host_info, f"mkdir -p {remote_dir}")
            
            # 上传文件
            sftp.put(local_path, remote_path)
            sftp.close()
            
            logger.info(f"文件上传成功: {local_path} -> {remote_path}")
            return True
            
        except Exception as e:
            logger.error(f"文件上传失败: {e}")
            return False
        finally:
            if client:
                client.close()


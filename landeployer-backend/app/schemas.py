"""
Pydantic模型（数据验证和序列化）
"""
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

# ============ Host ============
class HostBase(BaseModel):
    name: str
    ip: str
    port: int = 22
    username: str
    auth_type: str
    password: Optional[str] = None
    private_key: Optional[str] = None
    private_key_password: Optional[str] = None
    remote_path: str = "/opt/offline"
    group_name: Optional[str] = None
    description: Optional[str] = None

class HostCreate(HostBase):
    pass

class Host(HostBase):
    id: int
    status: str
    last_connect_time: Optional[datetime]
    create_time: datetime
    update_time: datetime
    
    class Config:
        from_attributes = True

# ============ DeployRole ============
class DeployRoleBase(BaseModel):
    code: str
    name: str
    tar_name: str
    compose_name: str
    ports: Optional[str] = None
    dependencies: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    sort_order: int = 0
    enabled: bool = True

class DeployRoleCreate(DeployRoleBase):
    pass

class DeployRole(DeployRoleBase):
    id: int
    create_time: datetime
    
    class Config:
        from_attributes = True

# ============ DeployTask ============
class DeployTaskBase(BaseModel):
    task_name: str
    host_id: int
    roles: str
    create_by: Optional[str] = "admin"

class DeployTaskCreate(DeployTaskBase):
    pass

class DeployTask(DeployTaskBase):
    id: int
    host_name: Optional[str]
    status: str
    progress: int
    logs: Optional[str]
    error_msg: Optional[str]
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    create_time: datetime
    
    class Config:
        from_attributes = True

# ============ 其他 ============
class ResponseModel(BaseModel):
    """统一响应模型"""
    code: int = 200
    message: str = "操作成功"
    data: Optional[any] = None
    timestamp: int = int(datetime.now().timestamp() * 1000)

class HostTestResult(BaseModel):
    """主机连接测试结果"""
    success: bool
    message: str
    os_info: Optional[str] = None
    docker_version: Optional[str] = None
    response_time: Optional[int] = None

class MissingPackage(BaseModel):
    """缺失的包"""
    role_code: str
    role_name: str
    package_name: str
    remote_path: str
    exists: bool = False


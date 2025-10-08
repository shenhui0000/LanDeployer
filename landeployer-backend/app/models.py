"""
数据库模型
"""
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Text
from datetime import datetime
from app.database import Base

class Host(Base):
    """服务器主机"""
    __tablename__ = "hosts"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    ip = Column(String(50), nullable=False)
    port = Column(Integer, default=22)
    username = Column(String(50), nullable=False)
    auth_type = Column(String(20), nullable=False)  # password, privateKey
    password = Column(String(500))
    private_key = Column(Text)
    private_key_password = Column(String(500))
    remote_path = Column(String(200), default="/opt/offline")
    group_name = Column(String(100))
    description = Column(String(500))
    status = Column(String(20), default="unknown")  # online, offline, unknown
    last_connect_time = Column(DateTime)
    create_time = Column(DateTime, default=datetime.now)
    update_time = Column(DateTime, default=datetime.now, onupdate=datetime.now)


class DeployRole(Base):
    """部署角色"""
    __tablename__ = "deploy_roles"
    
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String(50), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    tar_name = Column(String(200), nullable=False)
    compose_name = Column(String(200), nullable=False)
    ports = Column(String(500))
    dependencies = Column(String(500))
    description = Column(String(500))
    icon = Column(String(200))
    sort_order = Column(Integer, default=0)
    enabled = Column(Boolean, default=True)
    create_time = Column(DateTime, default=datetime.now)


class DeployTask(Base):
    """部署任务"""
    __tablename__ = "deploy_tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    task_name = Column(String(200), nullable=False)
    host_id = Column(Integer, nullable=False)
    host_name = Column(String(100))
    roles = Column(String(500), nullable=False)
    status = Column(String(20), default="pending")  # pending, running, success, failed
    progress = Column(Integer, default=0)
    logs = Column(Text)
    error_msg = Column(Text)
    start_time = Column(DateTime)
    end_time = Column(DateTime)
    create_time = Column(DateTime, default=datetime.now)
    create_by = Column(String(50))


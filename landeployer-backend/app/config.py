"""
配置文件
"""
from pydantic_settings import BaseSettings
from pathlib import Path

class Settings(BaseSettings):
    """应用配置"""
    
    # 基本配置
    APP_NAME: str = "LanDeployer"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # 服务器配置
    HOST: str = "0.0.0.0"
    PORT: int = 8080
    
    # 数据库配置
    DATABASE_URL: str = "sqlite:///./data/landeployer.db"
    
    # 文件存储
    STORAGE_PATH: str = "./storage"
    
    # SSH配置
    SSH_TIMEOUT: int = 30
    REMOTE_PATH: str = "/opt/offline"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()

# 确保目录存在
Path("data").mkdir(exist_ok=True)
Path("logs").mkdir(exist_ok=True)
Path("storage").mkdir(exist_ok=True)


"""
角色服务
"""
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models import DeployRole
from loguru import logger

def init_default_roles():
    """初始化默认角色"""
    db = SessionLocal()
    try:
        # 检查是否已有角色
        count = db.query(DeployRole).count()
        if count > 0:
            return
        
        logger.info("初始化默认部署角色...")
        
        roles = [
            {
                "code": "openresty",
                "name": "OpenResty",
                "tar_name": "openresty.tar",
                "compose_name": "openresty.yml",
                "ports": "80,443,9145",
                "dependencies": None,
                "description": "高性能Web平台",
                "icon": "🌐",
                "sort_order": 1
            },
            {
                "code": "redis",
                "name": "Redis",
                "tar_name": "redis.tar",
                "compose_name": "redis.yml",
                "ports": "6379,9121",
                "dependencies": None,
                "description": "缓存数据库",
                "icon": "🔴",
                "sort_order": 2
            },
            {
                "code": "mysql",
                "name": "MySQL",
                "tar_name": "mysql.tar",
                "compose_name": "mysql.yml",
                "ports": "3306,9104",
                "dependencies": None,
                "description": "关系型数据库",
                "icon": "🐬",
                "sort_order": 3
            },
            {
                "code": "prometheus",
                "name": "Prometheus",
                "tar_name": "prometheus.tar",
                "compose_name": "prometheus.yml",
                "ports": "9090",
                "dependencies": None,
                "description": "监控系统",
                "icon": "📊",
                "sort_order": 4
            },
            {
                "code": "grafana",
                "name": "Grafana",
                "tar_name": "grafana.tar",
                "compose_name": "grafana.yml",
                "ports": "3000",
                "dependencies": "prometheus",
                "description": "可视化面板",
                "icon": "📈",
                "sort_order": 5
            },
            {
                "code": "node-exporter",
                "name": "Node Exporter",
                "tar_name": "node-exporter.tar",
                "compose_name": "node-exporter.yml",
                "ports": "9100",
                "dependencies": None,
                "description": "节点监控",
                "icon": "💻",
                "sort_order": 6
            },
            {
                "code": "springboot",
                "name": "SpringBoot",
                "tar_name": "springboot.tar",
                "compose_name": "springboot.yml",
                "ports": "8080,8081",
                "dependencies": None,
                "description": "Java应用",
                "icon": "☕",
                "sort_order": 7
            }
        ]
        
        for role_data in roles:
            role = DeployRole(**role_data)
            db.add(role)
        
        db.commit()
        logger.info("默认角色初始化完成")
        
    except Exception as e:
        logger.error(f"初始化角色失败: {e}")
        db.rollback()
    finally:
        db.close()


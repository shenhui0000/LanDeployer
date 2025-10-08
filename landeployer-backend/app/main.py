"""
LanDeployer 主应用
离线内网一键部署工具 - Python版本
"""
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from loguru import logger
import os
import sys

from app.config import settings
from app.database import engine, Base
from app.routers import hosts, roles, deploy
from app.services.role_service import init_default_roles

# 创建数据库表
Base.metadata.create_all(bind=engine)

# 创建FastAPI应用
app = FastAPI(
    title="LanDeployer",
    description="离线内网一键部署工具",
    version="1.0.0"
)

# CORS配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 健康检查（必须在通配符路由之前）
@app.get("/api/health")
async def health_check():
    """健康检查"""
    return {"status": "healthy", "version": "1.0.0"}

# 注册路由
app.include_router(hosts.router, prefix="/api/hosts", tags=["主机管理"])
app.include_router(roles.router, prefix="/api/roles", tags=["角色管理"])
app.include_router(deploy.router, prefix="/api/deploy", tags=["部署管理"])

# 静态文件服务（前端）
# 静态文件在 landeployer-backend/static 目录
static_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "static")
if os.path.exists(static_dir):
    app.mount("/assets", StaticFiles(directory=os.path.join(static_dir, "assets")), name="assets")
    
    @app.get("/")
    async def read_root():
        index_path = os.path.join(static_dir, "index.html")
        if os.path.exists(index_path):
            return FileResponse(index_path)
        return {"message": "LanDeployer API"}
    
    # 支持Vue Router的HTML5 history模式
    # 所有非API和非静态资源的请求都返回index.html
    @app.get("/{full_path:path}")
    async def serve_spa(full_path: str):
        # 如果是API请求，不处理（会由其他路由处理）
        if full_path.startswith("api/"):
            return {"error": "Not found"}, 404
        
        # 返回index.html，让Vue Router处理前端路由
        index_path = os.path.join(static_dir, "index.html")
        if os.path.exists(index_path):
            return FileResponse(index_path)
        return {"message": "LanDeployer API"}
else:
    @app.get("/")
    async def read_root():
        return {"message": "LanDeployer API", "version": "1.0.0", "static_dir": static_dir}

@app.on_event("startup")
async def startup_event():
    """应用启动时的初始化"""
    logger.info("========================================")
    logger.info("LanDeployer 启动中...")
    logger.info("========================================")
    
    # 初始化默认角色
    init_default_roles()
    
    logger.info(f"访问地址: http://localhost:{settings.PORT}")
    logger.info("默认账号: admin / admin123")
    logger.info("========================================")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )


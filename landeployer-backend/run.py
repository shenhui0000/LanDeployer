#!/usr/bin/env python3
"""
LanDeployer 启动文件
"""
import uvicorn
from app.config import settings

if __name__ == "__main__":
    print("="*50)
    print("  LanDeployer 启动中...")
    print("="*50)
    
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=False
    )


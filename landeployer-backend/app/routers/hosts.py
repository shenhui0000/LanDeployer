"""
主机管理路由
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models import Host as HostModel
from app.schemas import Host, HostCreate, ResponseModel, HostTestResult
from app.services.ssh_service import SSHService

router = APIRouter()

@router.get("/", response_model=List[Host])
async def get_hosts(db: Session = Depends(get_db)):
    """查询所有主机"""
    hosts = db.query(HostModel).all()
    return [Host.model_validate(host) for host in hosts]

@router.get("/{host_id}", response_model=Host)
async def get_host(host_id: int, db: Session = Depends(get_db)):
    """根据ID查询主机"""
    host = db.query(HostModel).filter(HostModel.id == host_id).first()
    if not host:
        raise HTTPException(status_code=404, detail="主机不存在")
    return Host.model_validate(host)

@router.post("/", response_model=Host)
async def create_host(host: HostCreate, db: Session = Depends(get_db)):
    """创建主机"""
    db_host = HostModel(**host.model_dump())
    db.add(db_host)
    db.commit()
    db.refresh(db_host)
    return Host.model_validate(db_host)

@router.put("/{host_id}", response_model=Host)
async def update_host(host_id: int, host: HostCreate, db: Session = Depends(get_db)):
    """更新主机"""
    db_host = db.query(HostModel).filter(HostModel.id == host_id).first()
    if not db_host:
        raise HTTPException(status_code=404, detail="主机不存在")
    
    for key, value in host.model_dump().items():
        setattr(db_host, key, value)
    
    db_host.update_time = datetime.now()
    db.commit()
    db.refresh(db_host)
    return Host.model_validate(db_host)

@router.delete("/{host_id}")
async def delete_host(host_id: int, db: Session = Depends(get_db)):
    """删除主机"""
    db_host = db.query(HostModel).filter(HostModel.id == host_id).first()
    if not db_host:
        raise HTTPException(status_code=404, detail="主机不存在")
    
    db.delete(db_host)
    db.commit()
    return {"message": "删除成功"}

@router.post("/test", response_model=HostTestResult)
async def test_connection(host: HostCreate, db: Session = Depends(get_db)):
    """测试连接"""
    import time
    start_time = time.time()
    
    host_info = host.model_dump()
    success, message, os_info, docker_version = SSHService.test_connection(host_info)
    
    response_time = int((time.time() - start_time) * 1000)
    
    # 如果是已存在的主机，更新状态
    if hasattr(host, 'id') and host.id:
        db_host = db.query(HostModel).filter(HostModel.id == host.id).first()
        if db_host:
            db_host.status = "online" if success else "offline"
            if success:
                db_host.last_connect_time = datetime.now()
            db.commit()
    
    result = HostTestResult(
        success=success,
        message=message,
        os_info=os_info,
        docker_version=docker_version,
        response_time=response_time
    )
    
    return result

@router.get("/group/{group_name}", response_model=List[Host])
async def get_hosts_by_group(group_name: str, db: Session = Depends(get_db)):
    """根据分组查询主机"""
    hosts = db.query(HostModel).filter(HostModel.group_name == group_name).all()
    return [Host.model_validate(host) for host in hosts]


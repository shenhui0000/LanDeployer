"""
部署管理路由
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime

from app.database import get_db
from app.models import DeployTask as TaskModel, Host as HostModel, DeployRole as RoleModel
from app.schemas import DeployTask, DeployTaskCreate, ResponseModel, MissingPackage
from app.services.ssh_service import SSHService
from loguru import logger

router = APIRouter()

@router.post("/check", response_model=ResponseModel)
async def check_missing_packages(data: dict, db: Session = Depends(get_db)):
    """检查缺失的包"""
    host_id = data.get("hostId")
    role_codes = data.get("roleCodes", [])
    
    host = db.query(HostModel).filter(HostModel.id == host_id).first()
    if not host:
        raise HTTPException(status_code=404, detail="主机不存在")
    
    missing_list = []
    host_info = {
        "ip": host.ip,
        "port": host.port,
        "username": host.username,
        "auth_type": host.auth_type,
        "password": host.password,
        "private_key": host.private_key,
        "private_key_password": host.private_key_password
    }
    
    for code in role_codes:
        role = db.query(RoleModel).filter(RoleModel.code == code).first()
        if not role:
            continue
        
        image_path = f"{host.remote_path}/images/{role.tar_name}"
        compose_path = f"{host.remote_path}/compose/{role.compose_name}"
        
        # 检查镜像包
        if not SSHService.check_file_exists(host_info, image_path):
            missing_list.append(MissingPackage(
                role_code=code,
                role_name=role.name,
                package_name=role.tar_name,
                remote_path=image_path,
                exists=False
            ))
        
        # 检查compose文件
        if not SSHService.check_file_exists(host_info, compose_path):
            missing_list.append(MissingPackage(
                role_code=code,
                role_name=role.name,
                package_name=role.compose_name,
                remote_path=compose_path,
                exists=False
            ))
    
    return ResponseModel(data=missing_list)

def execute_deploy_task(task_id: int):
    """执行部署任务（后台任务）"""
    db = Session(bind=get_db.__next__().get_bind())
    
    try:
        task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
        if not task:
            return
        
        host = db.query(HostModel).filter(HostModel.id == task.host_id).first()
        if not host:
            task.status = "failed"
            task.error_msg = "主机不存在"
            task.end_time = datetime.now()
            db.commit()
            return
        
        # 更新任务状态
        task.status = "running"
        task.start_time = datetime.now()
        db.commit()
        
        host_info = {
            "ip": host.ip,
            "port": host.port,
            "username": host.username,
            "auth_type": host.auth_type,
            "password": host.password,
            "private_key": host.private_key,
            "private_key_password": host.private_key_password
        }
        
        logs = []
        role_codes = task.roles.split(',')
        total_steps = len(role_codes) * 3
        current_step = 0
        
        for code in role_codes:
            role = db.query(RoleModel).filter(RoleModel.code == code).first()
            if not role:
                continue
            
            logs.append(f"\n========== 开始部署 {role.name} ==========\n")
            
            # 1. 加载镜像
            logs.append("1. 加载Docker镜像...\n")
            load_cmd = f"cd {host.remote_path} && docker load -i images/{role.tar_name}"
            success, output = SSHService.execute_command(host_info, load_cmd)
            logs.append(output + "\n")
            
            current_step += 1
            task.progress = int((current_step / total_steps) * 100)
            task.logs = ''.join(logs)
            db.commit()
            
            # 2. 启动容器
            logs.append("2. 启动容器...\n")
            up_cmd = f"cd {host.remote_path} && docker-compose -f compose/{role.compose_name} up -d"
            success, output = SSHService.execute_command(host_info, up_cmd)
            logs.append(output + "\n")
            
            current_step += 1
            task.progress = int((current_step / total_steps) * 100)
            task.logs = ''.join(logs)
            db.commit()
            
            # 3. 验证状态
            logs.append("3. 验证容器状态...\n")
            ps_cmd = f"docker-compose -f {host.remote_path}/compose/{role.compose_name} ps"
            success, output = SSHService.execute_command(host_info, ps_cmd)
            logs.append(output + "\n")
            
            current_step += 1
            task.progress = int((current_step / total_steps) * 100)
            task.logs = ''.join(logs)
            db.commit()
            
            logs.append(f"✓ {role.name} 部署完成\n\n")
        
        # 任务完成
        task.status = "success"
        task.progress = 100
        task.end_time = datetime.now()
        task.logs = ''.join(logs)
        db.commit()
        
        logger.info(f"部署任务完成: {task_id}")
        
    except Exception as e:
        logger.error(f"部署任务失败: {e}")
        task.status = "failed"
        task.error_msg = str(e)
        task.end_time = datetime.now()
        db.commit()
    finally:
        db.close()

@router.post("/task", response_model=ResponseModel)
async def create_deploy_task(
    data: dict,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """创建部署任务"""
    task_name = data.get("taskName")
    host_id = data.get("hostId")
    role_codes = data.get("roleCodes", [])
    create_by = data.get("createBy", "admin")
    
    host = db.query(HostModel).filter(HostModel.id == host_id).first()
    if not host:
        raise HTTPException(status_code=404, detail="主机不存在")
    
    # 创建任务
    task = TaskModel(
        task_name=task_name,
        host_id=host_id,
        host_name=host.name,
        roles=','.join(role_codes),
        status="pending",
        progress=0,
        create_by=create_by
    )
    
    db.add(task)
    db.commit()
    db.refresh(task)
    
    # 异步执行任务
    background_tasks.add_task(execute_deploy_task, task.id)
    
    return ResponseModel(message="任务创建成功", data=task)

@router.get("/tasks", response_model=ResponseModel)
async def get_all_tasks(db: Session = Depends(get_db)):
    """查询所有任务"""
    tasks = db.query(TaskModel).order_by(TaskModel.create_time.desc()).all()
    return ResponseModel(data=tasks)

@router.get("/tasks/host/{host_id}", response_model=ResponseModel)
async def get_tasks_by_host(host_id: int, db: Session = Depends(get_db)):
    """根据主机ID查询任务"""
    tasks = db.query(TaskModel).filter(TaskModel.host_id == host_id).order_by(TaskModel.create_time.desc()).all()
    return ResponseModel(data=tasks)

@router.get("/tasks/{task_id}", response_model=ResponseModel)
async def get_task(task_id: int, db: Session = Depends(get_db)):
    """根据ID查询任务"""
    task = db.query(TaskModel).filter(TaskModel.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="任务不存在")
    return ResponseModel(data=task)


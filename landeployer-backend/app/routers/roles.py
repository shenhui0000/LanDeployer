"""
角色管理路由
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.models import DeployRole as RoleModel
from app.schemas import DeployRole, DeployRoleCreate, ResponseModel

router = APIRouter()

@router.get("/enabled", response_model=ResponseModel)
async def get_enabled_roles(db: Session = Depends(get_db)):
    """查询所有启用的角色"""
    roles = db.query(RoleModel).filter(RoleModel.enabled == True).order_by(RoleModel.sort_order).all()
    return ResponseModel(data=roles)

@router.get("/", response_model=ResponseModel)
async def get_all_roles(db: Session = Depends(get_db)):
    """查询所有角色"""
    roles = db.query(RoleModel).all()
    return ResponseModel(data=roles)

@router.get("/code/{code}", response_model=ResponseModel)
async def get_role_by_code(code: str, db: Session = Depends(get_db)):
    """根据code查询角色"""
    role = db.query(RoleModel).filter(RoleModel.code == code).first()
    if not role:
        raise HTTPException(status_code=404, detail="角色不存在")
    return ResponseModel(data=role)

@router.post("/", response_model=ResponseModel)
async def create_role(role: DeployRoleCreate, db: Session = Depends(get_db)):
    """创建角色"""
    db_role = RoleModel(**role.dict())
    db.add(db_role)
    db.commit()
    db.refresh(db_role)
    return ResponseModel(message="保存成功", data=db_role)

@router.delete("/{role_id}", response_model=ResponseModel)
async def delete_role(role_id: int, db: Session = Depends(get_db)):
    """删除角色"""
    role = db.query(RoleModel).filter(RoleModel.id == role_id).first()
    if not role:
        raise HTTPException(status_code=404, detail="角色不存在")
    
    db.delete(role)
    db.commit()
    return ResponseModel(message="删除成功")


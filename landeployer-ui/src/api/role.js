import request from './request'

// 查询所有启用的角色
export function getEnabledRoles() {
  return request({
    url: '/roles/enabled',
    method: 'get'
  })
}

// 查询所有角色
export function getRoles() {
  return request({
    url: '/roles',
    method: 'get'
  })
}

// 保存角色
export function saveRole(data) {
  return request({
    url: '/roles',
    method: 'post',
    data
  })
}

// 删除角色
export function deleteRole(id) {
  return request({
    url: `/roles/${id}`,
    method: 'delete'
  })
}


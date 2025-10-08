import request from './request'

// 检查缺失的包
export function checkMissingPackages(data) {
  return request({
    url: '/deploy/check',
    method: 'post',
    data
  })
}

// 创建部署任务
export function createDeployTask(data) {
  return request({
    url: '/deploy/task',
    method: 'post',
    data
  })
}

// 查询所有任务
export function getTasks() {
  return request({
    url: '/deploy/tasks',
    method: 'get'
  })
}

// 根据主机ID查询任务
export function getTasksByHost(hostId) {
  return request({
    url: `/deploy/tasks/host/${hostId}`,
    method: 'get'
  })
}

// 根据ID查询任务
export function getTask(id) {
  return request({
    url: `/deploy/tasks/${id}`,
    method: 'get'
  })
}


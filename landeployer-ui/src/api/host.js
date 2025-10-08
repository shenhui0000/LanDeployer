import request from './request'

// 查询所有主机
export function getHosts() {
  return request({
    url: '/hosts',
    method: 'get'
  })
}

// 根据ID查询主机
export function getHost(id) {
  return request({
    url: `/hosts/${id}`,
    method: 'get'
  })
}

// 保存主机
export function saveHost(data) {
  return request({
    url: '/hosts',
    method: 'post',
    data
  })
}

// 更新主机
export function updateHost(id, data) {
  return request({
    url: `/hosts/${id}`,
    method: 'put',
    data
  })
}

// 删除主机
export function deleteHost(id) {
  return request({
    url: `/hosts/${id}`,
    method: 'delete'
  })
}

// 测试连接
export function testConnection(data) {
  return request({
    url: '/hosts/test',
    method: 'post',
    data
  })
}


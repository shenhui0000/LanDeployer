import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/views/Layout.vue'

const routes = [
  {
    path: '/',
    component: Layout,
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '仪表盘', icon: 'Monitor' }
      },
      {
        path: 'hosts',
        name: 'Hosts',
        component: () => import('@/views/Hosts.vue'),
        meta: { title: '服务器管理', icon: 'Monitor' }
      },
      {
        path: 'roles',
        name: 'Roles',
        component: () => import('@/views/Roles.vue'),
        meta: { title: '资源仓库', icon: 'Box' }
      },
      {
        path: 'deploy',
        name: 'Deploy',
        component: () => import('@/views/Deploy.vue'),
        meta: { title: '部署任务', icon: 'Upload' }
      },
      {
        path: 'tasks',
        name: 'Tasks',
        component: () => import('@/views/Tasks.vue'),
        meta: { title: '任务历史', icon: 'List' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router


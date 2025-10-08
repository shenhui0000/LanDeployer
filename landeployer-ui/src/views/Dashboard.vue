<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#409eff"><Monitor /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalHosts }}</div>
              <div class="stat-label">服务器总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#67c23a"><SuccessFilled /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ stats.onlineHosts }}</div>
              <div class="stat-label">在线服务器</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#e6a23c"><Upload /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalTasks }}</div>
              <div class="stat-label">部署任务</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card class="stat-card">
          <div class="stat-content">
            <el-icon class="stat-icon" color="#f56c6c"><CircleCheck /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ stats.successTasks }}</div>
              <div class="stat-label">成功任务</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-card class="welcome-card" style="margin-top: 20px;">
      <h2>欢迎使用 LanDeployer</h2>
      <p>离线内网一键部署工具，支持OpenResty、Redis、MySQL、Prometheus、Grafana等服务的快速部署。</p>
      
      <div class="quick-actions">
        <el-button type="primary" @click="$router.push('/hosts')">
          <el-icon><Monitor /></el-icon>
          管理服务器
        </el-button>
        <el-button type="success" @click="$router.push('/deploy')">
          <el-icon><Upload /></el-icon>
          创建部署
        </el-button>
        <el-button type="info" @click="$router.push('/tasks')">
          <el-icon><List /></el-icon>
          查看任务
        </el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getHosts } from '@/api/host'
import { getTasks } from '@/api/deploy'

const stats = ref({
  totalHosts: 0,
  onlineHosts: 0,
  totalTasks: 0,
  successTasks: 0
})

const loadStats = async () => {
  try {
    // 加载主机统计
    const hostsRes = await getHosts()
    if (hostsRes.data) {
      stats.value.totalHosts = hostsRes.data.length
      stats.value.onlineHosts = hostsRes.data.filter(h => h.status === 'online').length
    }
    
    // 加载任务统计
    const tasksRes = await getTasks()
    if (tasksRes.data) {
      stats.value.totalTasks = tasksRes.data.length
      stats.value.successTasks = tasksRes.data.filter(t => t.status === 'success').length
    }
  } catch (error) {
    console.error('加载统计数据失败', error)
  }
}

onMounted(() => {
  loadStats()
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.stat-card {
  height: 120px;
}

.stat-content {
  display: flex;
  align-items: center;
  height: 100%;
}

.stat-icon {
  font-size: 48px;
  margin-right: 20px;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #303133;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 5px;
}

.welcome-card {
  padding: 30px;
}

.welcome-card h2 {
  color: #303133;
  margin-bottom: 15px;
}

.welcome-card p {
  color: #606266;
  margin-bottom: 30px;
}

.quick-actions {
  display: flex;
  gap: 15px;
}
</style>


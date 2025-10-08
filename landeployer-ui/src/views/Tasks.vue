<template>
  <div class="tasks-page">
    <el-card>
      <div class="toolbar">
        <h3>任务历史</h3>
        <el-button @click="loadTasks">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
      
      <el-table :data="tasks" v-loading="loading" style="margin-top: 20px;">
        <el-table-column prop="taskName" label="任务名称" width="250" show-overflow-tooltip />
        <el-table-column prop="hostName" label="服务器" width="150" />
        <el-table-column label="角色" width="250">
          <template #default="{ row }">
            <el-tag v-for="role in row.roles.split(',')" :key="role" size="small" style="margin-right: 5px;">
              {{ role }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'pending'" type="info">等待中</el-tag>
            <el-tag v-else-if="row.status === 'running'" type="warning">
              <el-icon class="is-loading"><Loading /></el-icon>
              执行中
            </el-tag>
            <el-tag v-else-if="row.status === 'success'" type="success">成功</el-tag>
            <el-tag v-else-if="row.status === 'failed'" type="danger">失败</el-tag>
            <el-tag v-else type="info">已取消</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="进度" width="150">
          <template #default="{ row }">
            <el-progress :percentage="row.progress" :status="row.status === 'failed' ? 'exception' : (row.status === 'success' ? 'success' : '')" />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="viewDetails(row)">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 详情对话框 -->
    <el-dialog
      v-model="detailsVisible"
      title="任务详情"
      width="800px"
    >
      <el-descriptions :column="2" border v-if="currentTask">
        <el-descriptions-item label="任务名称" :span="2">
          {{ currentTask.taskName }}
        </el-descriptions-item>
        <el-descriptions-item label="服务器">
          {{ currentTask.hostName }}
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag v-if="currentTask.status === 'success'" type="success">成功</el-tag>
          <el-tag v-else-if="currentTask.status === 'failed'" type="danger">失败</el-tag>
          <el-tag v-else-if="currentTask.status === 'running'" type="warning">执行中</el-tag>
          <el-tag v-else type="info">{{ currentTask.status }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="进度">
          {{ currentTask.progress }}%
        </el-descriptions-item>
        <el-descriptions-item label="创建人">
          {{ currentTask.createBy }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">
          {{ currentTask.createTime }}
        </el-descriptions-item>
        <el-descriptions-item label="开始时间">
          {{ currentTask.startTime || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="结束时间">
          {{ currentTask.endTime || '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="错误信息" :span="2" v-if="currentTask.errorMsg">
          <el-alert :title="currentTask.errorMsg" type="error" :closable="false" />
        </el-descriptions-item>
      </el-descriptions>
      
      <div style="margin-top: 20px;">
        <h4>执行日志</h4>
        <el-input
          v-model="currentTask.logs"
          type="textarea"
          :rows="15"
          readonly
          style="margin-top: 10px; font-family: monospace;"
        />
      </div>
      
      <template #footer>
        <el-button @click="detailsVisible = false">关闭</el-button>
        <el-button type="primary" @click="refreshTask" v-if="currentTask && currentTask.status === 'running'">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getTasks, getTask } from '@/api/deploy'

const loading = ref(false)
const tasks = ref([])
const detailsVisible = ref(false)
const currentTask = ref(null)
let refreshTimer = null

const loadTasks = async () => {
  loading.value = true
  try {
    const res = await getTasks()
    tasks.value = res.data || []
  } catch (error) {
    ElMessage.error('加载任务列表失败')
  } finally {
    loading.value = false
  }
}

const viewDetails = async (row) => {
  try {
    const res = await getTask(row.id)
    currentTask.value = res.data
    detailsVisible.value = true
    
    // 如果任务正在运行，启动自动刷新
    if (currentTask.value.status === 'running') {
      startAutoRefresh()
    }
  } catch (error) {
    ElMessage.error('加载任务详情失败')
  }
}

const refreshTask = async () => {
  if (!currentTask.value) return
  
  try {
    const res = await getTask(currentTask.value.id)
    currentTask.value = res.data
    
    // 如果任务已完成，停止自动刷新
    if (currentTask.value.status !== 'running') {
      stopAutoRefresh()
      loadTasks() // 刷新列表
    }
  } catch (error) {
    ElMessage.error('刷新任务失败')
  }
}

const startAutoRefresh = () => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
  refreshTimer = setInterval(() => {
    refreshTask()
  }, 3000) // 每3秒刷新一次
}

const stopAutoRefresh = () => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
}

onMounted(() => {
  loadTasks()
  
  // 设置自动刷新任务列表
  const listRefreshTimer = setInterval(() => {
    loadTasks()
  }, 10000) // 每10秒刷新一次列表
  
  // 组件卸载时清除定时器
  onUnmounted(() => {
    clearInterval(listRefreshTimer)
    stopAutoRefresh()
  })
})

const onUnmounted = (callback) => {
  // Vue 3 onUnmounted hook
  const { onUnmounted: vueOnUnmounted } = require('vue')
  vueOnUnmounted(callback)
}
</script>

<style scoped>
.tasks-page {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>


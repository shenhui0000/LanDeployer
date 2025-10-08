<template>
  <div class="deploy-page">
    <el-card>
      <el-steps :active="currentStep" align-center style="margin-bottom: 30px;">
        <el-step title="选择服务器" />
        <el-step title="选择角色" />
        <el-step title="检查资源" />
        <el-step title="开始部署" />
      </el-steps>
      
      <!-- 步骤1: 选择服务器 -->
      <div v-if="currentStep === 0">
        <h3>选择目标服务器</h3>
        <el-table
          :data="hosts"
          v-loading="loading"
          @selection-change="handleHostSelect"
          style="margin-top: 20px;"
        >
          <el-table-column type="selection" width="55" :selectable="row => row.status === 'online'" />
          <el-table-column prop="name" label="名称" width="150" />
          <el-table-column prop="ip" label="IP地址" width="150" />
          <el-table-column prop="remotePath" label="部署路径" width="200" />
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag v-if="row.status === 'online'" type="success">在线</el-tag>
              <el-tag v-else type="danger">离线</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="description" label="描述" show-overflow-tooltip />
        </el-table>
        
        <div class="step-footer">
          <el-button type="primary" :disabled="selectedHost === null" @click="nextStep">
            下一步
          </el-button>
        </div>
      </div>
      
      <!-- 步骤2: 选择角色 -->
      <div v-if="currentStep === 1">
        <h3>选择部署角色</h3>
        <div class="roles-grid">
          <el-card
            v-for="role in roles"
            :key="role.code"
            :class="['role-card', { selected: selectedRoles.includes(role.code) }]"
            @click="toggleRole(role.code)"
            shadow="hover"
          >
            <div class="role-icon">{{ role.icon }}</div>
            <div class="role-name">{{ role.name }}</div>
            <div class="role-desc">{{ role.description }}</div>
            <div class="role-ports">端口: {{ role.ports }}</div>
          </el-card>
        </div>
        
        <div class="step-footer">
          <el-button @click="prevStep">上一步</el-button>
          <el-button type="primary" :disabled="selectedRoles.length === 0" @click="checkPackages">
            下一步
          </el-button>
        </div>
      </div>
      
      <!-- 步骤3: 检查资源 -->
      <div v-if="currentStep === 2">
        <h3>检查服务器资源</h3>
        
        <el-alert
          v-if="missingPackages.length === 0"
          title="✓ 所有资源包已就绪"
          type="success"
          :closable="false"
          style="margin: 20px 0;"
        />
        
        <el-alert
          v-else
          title="⚠ 发现缺失的资源包"
          type="warning"
          :closable="false"
          style="margin: 20px 0;"
        />
        
        <el-table :data="missingPackages" v-if="missingPackages.length > 0" style="margin-top: 20px;">
          <el-table-column prop="roleName" label="角色" width="150" />
          <el-table-column prop="packageName" label="包名称" width="250" />
          <el-table-column prop="remotePath" label="远程路径" show-overflow-tooltip />
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag v-if="row.exists" type="success">已存在</el-tag>
              <el-tag v-else type="danger">缺失</el-tag>
            </template>
          </el-table-column>
        </el-table>
        
        <el-alert
          type="info"
          :closable="false"
          style="margin-top: 20px;"
        >
          <p>如发现缺失的包，请手动将对应文件上传到服务器的指定目录，或联系管理员。</p>
        </el-alert>
        
        <div class="step-footer">
          <el-button @click="prevStep">上一步</el-button>
          <el-button type="primary" @click="nextStep">
            下一步
          </el-button>
        </div>
      </div>
      
      <!-- 步骤4: 开始部署 -->
      <div v-if="currentStep === 3">
        <h3>确认部署信息</h3>
        
        <el-descriptions :column="2" border style="margin-top: 20px;">
          <el-descriptions-item label="目标服务器">
            {{ selectedHost?.name }} ({{ selectedHost?.ip }})
          </el-descriptions-item>
          <el-descriptions-item label="部署路径">
            {{ selectedHost?.remotePath }}
          </el-descriptions-item>
          <el-descriptions-item label="部署角色" :span="2">
            <el-tag v-for="code in selectedRoles" :key="code" style="margin-right: 5px;">
              {{ roles.find(r => r.code === code)?.name }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
        
        <el-form :model="deployForm" style="margin-top: 30px; max-width: 500px;">
          <el-form-item label="任务名称">
            <el-input v-model="deployForm.taskName" placeholder="请输入任务名称" />
          </el-form-item>
        </el-form>
        
        <div class="step-footer">
          <el-button @click="prevStep">上一步</el-button>
          <el-button type="success" @click="startDeploy" :loading="deploying">
            <el-icon><Upload /></el-icon>
            开始部署
          </el-button>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getHosts } from '@/api/host'
import { getEnabledRoles } from '@/api/role'
import { checkMissingPackages, createDeployTask } from '@/api/deploy'

const router = useRouter()
const loading = ref(false)
const deploying = ref(false)
const currentStep = ref(0)

const hosts = ref([])
const roles = ref([])
const selectedHost = ref(null)
const selectedRoles = ref([])
const missingPackages = ref([])

const deployForm = ref({
  taskName: ''
})

const loadHosts = async () => {
  loading.value = true
  try {
    const res = await getHosts()
    hosts.value = res.data || []
  } catch (error) {
    ElMessage.error('加载服务器列表失败')
  } finally {
    loading.value = false
  }
}

const loadRoles = async () => {
  try {
    const res = await getEnabledRoles()
    roles.value = res.data || []
  } catch (error) {
    ElMessage.error('加载角色列表失败')
  }
}

const handleHostSelect = (selection) => {
  selectedHost.value = selection.length > 0 ? selection[0] : null
}

const toggleRole = (code) => {
  const index = selectedRoles.value.indexOf(code)
  if (index > -1) {
    selectedRoles.value.splice(index, 1)
  } else {
    selectedRoles.value.push(code)
  }
}

const checkPackages = async () => {
  loading.value = true
  try {
    const res = await checkMissingPackages({
      hostId: selectedHost.value.id,
      roleCodes: selectedRoles.value
    })
    missingPackages.value = res.data || []
    nextStep()
  } catch (error) {
    ElMessage.error('检查资源包失败')
  } finally {
    loading.value = false
  }
}

const startDeploy = async () => {
  if (!deployForm.value.taskName) {
    ElMessage.warning('请输入任务名称')
    return
  }
  
  deploying.value = true
  try {
    const res = await createDeployTask({
      taskName: deployForm.value.taskName,
      hostId: selectedHost.value.id,
      roleCodes: selectedRoles.value,
      createBy: 'admin'
    })
    
    ElMessage.success('部署任务已创建')
    router.push(`/tasks`)
  } catch (error) {
    ElMessage.error('创建部署任务失败')
  } finally {
    deploying.value = false
  }
}

const nextStep = () => {
  if (currentStep.value < 3) {
    currentStep.value++
  }
}

const prevStep = () => {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

onMounted(() => {
  loadHosts()
  loadRoles()
  
  // 生成默认任务名称
  const now = new Date()
  deployForm.value.taskName = `部署任务_${now.getFullYear()}${(now.getMonth()+1).toString().padStart(2,'0')}${now.getDate().toString().padStart(2,'0')}_${now.getHours().toString().padStart(2,'0')}${now.getMinutes().toString().padStart(2,'0')}`
})
</script>

<style scoped>
.deploy-page {
  padding: 20px;
}

.roles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.role-card {
  cursor: pointer;
  text-align: center;
  padding: 20px;
  transition: all 0.3s;
}

.role-card:hover {
  transform: translateY(-5px);
}

.role-card.selected {
  border: 2px solid #409eff;
  background-color: #ecf5ff;
}

.role-icon {
  font-size: 48px;
  margin-bottom: 10px;
}

.role-name {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
}

.role-desc {
  font-size: 12px;
  color: #909399;
  margin-bottom: 5px;
}

.role-ports {
  font-size: 12px;
  color: #606266;
}

.step-footer {
  margin-top: 30px;
  text-align: right;
}
</style>


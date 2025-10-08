<template>
  <div class="hosts-page">
    <el-card>
      <div class="toolbar">
        <el-button type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          添加服务器
        </el-button>
        <el-button @click="loadHosts">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
      
      <el-table :data="hosts" v-loading="loading" style="margin-top: 20px;">
        <el-table-column prop="name" label="名称" width="150" />
        <el-table-column prop="ip" label="IP地址" width="150" />
        <el-table-column prop="port" label="端口" width="80" />
        <el-table-column prop="username" label="用户名" width="100" />
        <el-table-column prop="remotePath" label="部署路径" width="180" />
        <el-table-column prop="groupName" label="分组" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'online'" type="success">在线</el-tag>
            <el-tag v-else-if="row.status === 'offline'" type="danger">离线</el-tag>
            <el-tag v-else type="info">未知</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column label="操作" width="260" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleTest(row)">测试</el-button>
            <el-button size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 添加/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="120px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入主机名称" />
        </el-form-item>
        
        <el-form-item label="IP地址" prop="ip">
          <el-input v-model="form.ip" placeholder="请输入IP地址" />
        </el-form-item>
        
        <el-form-item label="端口" prop="port">
          <el-input-number v-model="form.port" :min="1" :max="65535" />
        </el-form-item>
        
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>
        
        <el-form-item label="认证方式" prop="authType">
          <el-radio-group v-model="form.authType">
            <el-radio label="password">密码</el-radio>
            <el-radio label="privateKey">私钥</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <el-form-item v-if="form.authType === 'password'" label="密码" prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        
        <el-form-item v-if="form.authType === 'privateKey'" label="私钥" prop="privateKey">
          <el-input v-model="form.privateKey" type="textarea" :rows="4" placeholder="请输入私钥内容" />
        </el-form-item>
        
        <el-form-item label="部署路径" prop="remotePath">
          <el-input v-model="form.remotePath" placeholder="/opt/offline" />
        </el-form-item>
        
        <el-form-item label="分组">
          <el-input v-model="form.groupName" placeholder="请输入分组名称" />
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getHosts, saveHost, updateHost, deleteHost, testConnection } from '@/api/host'

const loading = ref(false)
const hosts = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('添加服务器')
const formRef = ref(null)

const form = ref({
  name: '',
  ip: '',
  port: 22,
  username: 'root',
  authType: 'password',
  password: '',
  privateKey: '',
  remotePath: '/opt/offline',
  groupName: '',
  description: ''
})

const rules = {
  name: [{ required: true, message: '请输入主机名称', trigger: 'blur' }],
  ip: [{ required: true, message: '请输入IP地址', trigger: 'blur' }],
  port: [{ required: true, message: '请输入端口', trigger: 'blur' }],
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  authType: [{ required: true, message: '请选择认证方式', trigger: 'change' }],
  remotePath: [{ required: true, message: '请输入部署路径', trigger: 'blur' }]
}

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

const handleAdd = () => {
  dialogTitle.value = '添加服务器'
  form.value = {
    name: '',
    ip: '',
    port: 22,
    username: 'root',
    authType: 'password',
    password: '',
    privateKey: '',
    remotePath: '/opt/offline',
    groupName: '',
    description: ''
  }
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑服务器'
  form.value = { ...row }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  await formRef.value.validate()
  
  try {
    if (form.value.id) {
      await updateHost(form.value.id, form.value)
      ElMessage.success('更新成功')
    } else {
      await saveHost(form.value)
      ElMessage.success('添加成功')
    }
    dialogVisible.value = false
    loadHosts()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除这台服务器吗？', '提示', {
      type: 'warning'
    })
    
    await deleteHost(row.id)
    ElMessage.success('删除成功')
    loadHosts()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleTest = async (row) => {
  const loadingMsg = ElMessage.loading('正在测试连接...')
  try {
    const res = await testConnection(row)
    loadingMsg.close()
    
    if (res.data && res.data.success) {
      ElMessage.success(`连接成功！响应时间: ${res.data.responseTime}ms`)
      loadHosts()
    } else {
      ElMessage.error(res.data?.message || '连接失败')
    }
  } catch (error) {
    loadingMsg.close()
    ElMessage.error('测试失败')
  }
}

onMounted(() => {
  loadHosts()
})
</script>

<style scoped>
.hosts-page {
  padding: 20px;
}

.toolbar {
  display: flex;
  gap: 10px;
}
</style>


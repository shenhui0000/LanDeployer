<template>
  <div class="roles-page">
    <el-card>
      <div class="toolbar">
        <h3>资源仓库</h3>
        <el-button @click="loadRoles">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
      
      <el-table :data="roles" v-loading="loading" style="margin-top: 20px;">
        <el-table-column label="图标" width="80">
          <template #default="{ row }">
            <span style="font-size: 24px;">{{ row.icon }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="名称" width="150" />
        <el-table-column prop="code" label="编码" width="150" />
        <el-table-column prop="tarName" label="镜像包" width="200" />
        <el-table-column prop="composeName" label="Compose文件" width="200" />
        <el-table-column prop="ports" label="端口" width="150" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.enabled" type="success">启用</el-tag>
            <el-tag v-else type="info">禁用</el-tag>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="tip-box">
        <el-alert
          title="提示"
          type="info"
          :closable="false"
          style="margin-top: 20px;"
        >
          <p>离线包需要放置在服务器的指定目录：</p>
          <ul>
            <li>镜像tar包：/opt/offline/images/</li>
            <li>Compose文件：/opt/offline/compose/</li>
            <li>配置文件：/opt/offline/config/</li>
          </ul>
          <p>可以通过"部署任务"页面检查缺失的包并上传。</p>
        </el-alert>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getRoles } from '@/api/role'

const loading = ref(false)
const roles = ref([])

const loadRoles = async () => {
  loading.value = true
  try {
    const res = await getRoles()
    roles.value = res.data || []
  } catch (error) {
    ElMessage.error('加载角色列表失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadRoles()
})
</script>

<style scoped>
.roles-page {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tip-box {
  margin-top: 20px;
}

.tip-box ul {
  margin: 10px 0;
  padding-left: 20px;
}

.tip-box li {
  margin: 5px 0;
}
</style>


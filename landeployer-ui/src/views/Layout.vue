<template>
  <el-container class="layout-container">
    <el-aside width="200px" class="sidebar">
      <div class="logo">
        <h2>🚀 LanDeployer</h2>
      </div>
      <el-menu
        :default-active="$route.path"
        router
        class="menu"
      >
        <el-menu-item index="/dashboard">
          <el-icon><Monitor /></el-icon>
          <span>仪表盘</span>
        </el-menu-item>
        <el-menu-item index="/hosts">
          <el-icon><Monitor /></el-icon>
          <span>服务器管理</span>
        </el-menu-item>
        <el-menu-item index="/roles">
          <el-icon><Box /></el-icon>
          <span>资源仓库</span>
        </el-menu-item>
        <el-menu-item index="/deploy">
          <el-icon><Upload /></el-icon>
          <span>部署任务</span>
        </el-menu-item>
        <el-menu-item index="/tasks">
          <el-icon><List /></el-icon>
          <span>任务历史</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    
    <el-container>
      <el-header class="header">
        <div class="header-left">
          <h3>{{ $route.meta.title || '离线内网部署工具' }}</h3>
        </div>
        <div class="header-right">
          <span class="username">管理员</span>
        </div>
      </el-header>
      
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.sidebar {
  background-color: #304156;
  color: #fff;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #263445;
  color: #fff;
}

.logo h2 {
  font-size: 20px;
  font-weight: 600;
}

.menu {
  border: none;
  background-color: #304156;
}

:deep(.el-menu-item) {
  color: #bfcbd9;
}

:deep(.el-menu-item:hover) {
  background-color: #263445 !important;
  color: #fff;
}

:deep(.el-menu-item.is-active) {
  background-color: #409eff !important;
  color: #fff;
}

.header {
  background-color: #fff;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
}

.header-left h3 {
  font-size: 18px;
  color: #303133;
}

.header-right {
  display: flex;
  align-items: center;
}

.username {
  color: #606266;
  margin-right: 10px;
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
}
</style>


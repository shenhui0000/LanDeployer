#!/bin/bash

# GitHub Release 创建脚本
# 使用前请先登录: gh auth login

set -e

echo "========================================="
echo "创建 GitHub Release v1.0.0"
echo "========================================="
echo ""

# 检查是否已登录
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ 未登录 GitHub CLI"
    echo ""
    echo "请先运行: gh auth login"
    exit 1
fi

echo "✓ 已登录 GitHub"
echo ""

# 检查文件是否存在
echo "检查文件..."
if [ ! -f "dist/landeployer-python-darwin-arm64.tar.gz" ]; then
    echo "❌ 未找到可执行程序包"
    exit 1
fi

image_count=$(ls images/*.tar 2>/dev/null | wc -l | tr -d ' ')
if [ "$image_count" -eq "0" ]; then
    echo "❌ 未找到 Docker 镜像文件"
    exit 1
fi

echo "✓ 可执行程序包: dist/landeployer-python-darwin-arm64.tar.gz"
echo "✓ Docker 镜像数量: $image_count 个"
echo ""

# 创建 Release
echo "创建 Release..."
gh release create v1.0.0 \
  --title "LanDeployer v1.0.0" \
  --notes "首个正式版本，包含完整的 Docker 镜像和可执行程序

## ✨ 功能特性

- 🚀 离线内网一键部署 Docker 服务
- 🎯 支持多种常用服务（OpenResty、Redis、MySQL、Prometheus、Grafana 等）
- 💻 友好的 Web UI 界面（Vue 3 + Element Plus）
- 🔧 SSH 远程执行部署任务
- 📊 实时查看部署进度和日志
- 🐳 Docker Compose 配置管理

## 📦 下载内容

### 1. 可执行程序（macOS ARM64）
- **landeployer-python-darwin-arm64.tar.gz** (15MB)
  - 包含 Python 运行环境
  - 无需安装依赖
  - 解压即用

### 2. Docker 镜像包（AMD64 架构，共约 1.8GB）
- **openresty.tar** (102MB) - OpenResty Web 服务器
- **redis.tar** (114MB) - Redis 缓存数据库
- **redis-exporter.tar** (9.2MB) - Redis 监控导出器
- **mysql.tar** (579MB) - MySQL 8.0.35 数据库
- **mysqld-exporter.tar** (20MB) - MySQL 监控导出器
- **prometheus.tar** (227MB) - Prometheus 监控系统
- **node-exporter.tar** (23MB) - 节点监控导出器
- **grafana.tar** (318MB) - Grafana 可视化平台
- **temurin-jdk8.tar** (184MB) - Eclipse Temurin JDK 8
- **tomcat9-jdk8.tar** (293MB) - Tomcat 9 + JDK 8

## 🚀 快速开始

### 运行程序

\`\`\`bash
# 下载并解压
wget https://github.com/shenhui0000/LanDeployer/releases/download/v1.0.0/landeployer-python-darwin-arm64.tar.gz
tar xzf landeployer-python-darwin-arm64.tar.gz
cd landeployer-release

# 启动服务
./start.sh
\`\`\`

### 导入 Docker 镜像

\`\`\`bash
# 下载镜像文件
wget https://github.com/shenhui0000/LanDeployer/releases/download/v1.0.0/openresty.tar
# ... 下载其他需要的镜像

# 导入镜像
docker load -i openresty.tar
\`\`\`

## 📖 使用说明

1. 启动程序后访问 http://localhost:8080
2. 默认账号：admin / admin123
3. 在「主机管理」中添加目标服务器
4. 在「部署任务」中选择要部署的服务
5. 查看部署进度和日志

## 🔧 系统要求

- macOS ARM64（M1/M2/M3 芯片）
- 目标服务器需要 Docker 和 Docker Compose
- 目标服务器架构：AMD64 (x86_64)

## 📝 更新日志

- 初始发布
- 支持 7 种常用服务部署
- 完整的 Web UI 管理界面
- JDK 版本为 1.8

---

**仓库地址**: https://github.com/shenhui0000/LanDeployer
**问题反馈**: https://github.com/shenhui0000/LanDeployer/issues" \
  dist/landeployer-python-darwin-arm64.tar.gz \
  images/*.tar

echo ""
echo "========================================="
echo "✅ Release 创建成功！"
echo "========================================="
echo ""
echo "访问地址："
echo "https://github.com/shenhui0000/LanDeployer/releases/tag/v1.0.0"
echo ""


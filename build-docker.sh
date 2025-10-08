#!/bin/bash
# LanDeployer Docker镜像构建脚本

set -e

echo "========================================="
echo "  LanDeployer Docker镜像构建"
echo "========================================="
echo ""

# 1. 构建项目
echo "1. 构建项目..."
bash build.sh

# 2. 构建Docker镜像
echo ""
echo "========================================="
echo "2. 构建Docker镜像..."
echo "========================================="
echo ""

docker build -t landeployer:latest .

echo "✓ Docker镜像构建完成"
echo ""

# 3. 保存为tar包（用于离线部署）
echo "========================================="
echo "3. 导出Docker镜像（离线部署用）..."
echo "========================================="
echo ""

docker save -o landeployer-docker.tar landeployer:latest

echo "✓ Docker镜像已导出: landeployer-docker.tar"
echo ""

# 显示镜像信息
echo "========================================="
echo "镜像信息："
echo "========================================="
docker images | grep landeployer

echo ""
echo "========================================="
echo "使用方法："
echo "========================================="
echo ""
echo "方式1 - Docker Compose（推荐）："
echo "  docker-compose -f docker-compose-landeployer.yml up -d"
echo ""
echo "方式2 - Docker命令："
echo "  docker run -d -p 8080:8080 \\"
echo "    -v \$(pwd)/data:/app/data \\"
echo "    -v \$(pwd)/logs:/app/logs \\"
echo "    --name landeployer landeployer:latest"
echo ""
echo "方式3 - 离线部署："
echo "  1. 将 landeployer-docker.tar 拷贝到目标机器"
echo "  2. docker load -i landeployer-docker.tar"
echo "  3. docker run -d -p 8080:8080 --name landeployer landeployer:latest"
echo ""
echo "访问地址: http://localhost:8080"
echo "========================================="

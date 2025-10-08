#!/bin/bash
# LanDeployer 安装脚本

set -e

echo "========================================="
echo "  LanDeployer 安装脚本"
echo "========================================="
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
   echo "请使用root用户运行此脚本"
   exit 1
fi

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装，请先安装Docker"
    exit 1
fi

# 检查Docker Compose是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: Docker Compose未安装，请先安装Docker Compose"
    exit 1
fi

echo "✓ Docker检查通过"
echo "✓ Docker Compose检查通过"
echo ""

# 创建目录结构
BASE_DIR="/opt/offline"
echo "创建目录结构: $BASE_DIR"

mkdir -p "$BASE_DIR"/{images,compose,config,app,logs}
mkdir -p "$BASE_DIR/config"/{openresty/conf.d,prometheus,grafana/provisioning/{datasources,dashboards},springboot}

echo "✓ 目录创建完成"
echo ""

# 复制脚本和配置文件
echo "复制脚本和配置文件..."

if [ -f "load.sh" ]; then
    cp load.sh "$BASE_DIR/"
    chmod +x "$BASE_DIR/load.sh"
fi

if [ -d "compose" ]; then
    cp compose/*.yml "$BASE_DIR/compose/"
fi

if [ -d "config" ]; then
    cp -r config/* "$BASE_DIR/config/"
fi

echo "✓ 文件复制完成"
echo ""

echo "========================================="
echo "安装完成!"
echo ""
echo "目录结构:"
echo "  $BASE_DIR/images/        - 存放Docker镜像tar包"
echo "  $BASE_DIR/compose/       - 存放docker-compose文件"
echo "  $BASE_DIR/config/        - 存放配置文件"
echo "  $BASE_DIR/app/           - 存放应用程序"
echo "  $BASE_DIR/logs/          - 存放日志文件"
echo ""
echo "使用方法:"
echo "  1. 将镜像tar包放入 $BASE_DIR/images/ 目录"
echo "  2. 运行 $BASE_DIR/load.sh 加载镜像"
echo "  3. 使用 docker-compose -f $BASE_DIR/compose/<service>.yml up -d 启动服务"
echo "========================================="


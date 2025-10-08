#!/bin/bash

# 镜像打包脚本
# 将相关的镜像打包到一起，方便分发

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

IMAGES_DIR="./images"
PACKAGES_DIR="./packages"

mkdir -p "$PACKAGES_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}镜像打包工具${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查镜像目录
if [ ! -d "$IMAGES_DIR" ]; then
    echo "错误: 镜像目录不存在，请先运行 ./export-images.sh"
    exit 1
fi

# 打包 OpenResty 镜像包
echo -e "${YELLOW}打包 OpenResty...${NC}"
tar -czf "$PACKAGES_DIR/openresty.tar.gz" \
    -C "$IMAGES_DIR" openresty.tar 2>/dev/null || \
    cp "$IMAGES_DIR/openresty.tar" "$PACKAGES_DIR/openresty.tar"
echo -e "${GREEN}✓ 完成${NC}"
echo ""

# 打包 Redis 镜像包（包含 exporter）
echo -e "${YELLOW}打包 Redis（包含 exporter）...${NC}"
if [ -f "$IMAGES_DIR/redis.tar" ] && [ -f "$IMAGES_DIR/redis-exporter.tar" ]; then
    tar -czf "$PACKAGES_DIR/redis.tar.gz" \
        -C "$IMAGES_DIR" redis.tar redis-exporter.tar 2>/dev/null || {
        mkdir -p /tmp/redis_package
        cp "$IMAGES_DIR/redis.tar" /tmp/redis_package/
        cp "$IMAGES_DIR/redis-exporter.tar" /tmp/redis_package/
        tar -czf "$PACKAGES_DIR/redis.tar.gz" -C /tmp redis_package
        rm -rf /tmp/redis_package
    }
    echo -e "${GREEN}✓ 完成${NC}"
else
    echo -e "${YELLOW}! 跳过（文件不存在）${NC}"
fi
echo ""

# 打包 MySQL 镜像包（包含 exporter）
echo -e "${YELLOW}打包 MySQL（包含 exporter）...${NC}"
if [ -f "$IMAGES_DIR/mysql.tar" ] && [ -f "$IMAGES_DIR/mysqld-exporter.tar" ]; then
    tar -czf "$PACKAGES_DIR/mysql.tar.gz" \
        -C "$IMAGES_DIR" mysql.tar mysqld-exporter.tar 2>/dev/null || {
        mkdir -p /tmp/mysql_package
        cp "$IMAGES_DIR/mysql.tar" /tmp/mysql_package/
        cp "$IMAGES_DIR/mysqld-exporter.tar" /tmp/mysql_package/
        tar -czf "$PACKAGES_DIR/mysql.tar.gz" -C /tmp mysql_package
        rm -rf /tmp/mysql_package
    }
    echo -e "${GREEN}✓ 完成${NC}"
else
    echo -e "${YELLOW}! 跳过（文件不存在）${NC}"
fi
echo ""

# 打包 Prometheus 和 Node Exporter
echo -e "${YELLOW}打包 Prometheus 和 Node Exporter...${NC}"
if [ -f "$IMAGES_DIR/prometheus.tar" ] && [ -f "$IMAGES_DIR/node-exporter.tar" ]; then
    tar -czf "$PACKAGES_DIR/prometheus.tar.gz" \
        -C "$IMAGES_DIR" prometheus.tar node-exporter.tar 2>/dev/null || {
        mkdir -p /tmp/prometheus_package
        cp "$IMAGES_DIR/prometheus.tar" /tmp/prometheus_package/
        cp "$IMAGES_DIR/node-exporter.tar" /tmp/prometheus_package/
        tar -czf "$PACKAGES_DIR/prometheus.tar.gz" -C /tmp prometheus_package
        rm -rf /tmp/prometheus_package
    }
    echo -e "${GREEN}✓ 完成${NC}"
else
    echo -e "${YELLOW}! 跳过（文件不存在）${NC}"
fi
echo ""

# 打包 Grafana
echo -e "${YELLOW}打包 Grafana...${NC}"
tar -czf "$PACKAGES_DIR/grafana.tar.gz" \
    -C "$IMAGES_DIR" grafana.tar 2>/dev/null || \
    cp "$IMAGES_DIR/grafana.tar" "$PACKAGES_DIR/grafana.tar"
echo -e "${GREEN}✓ 完成${NC}"
echo ""

# 打包 SpringBoot 相关镜像
echo -e "${YELLOW}打包 SpringBoot 镜像...${NC}"
if [ -f "$IMAGES_DIR/temurin-jdk8.tar" ] && [ -f "$IMAGES_DIR/tomcat9-jdk8.tar" ]; then
    tar -czf "$PACKAGES_DIR/springboot.tar.gz" \
        -C "$IMAGES_DIR" temurin-jdk8.tar tomcat9-jdk8.tar 2>/dev/null || {
        mkdir -p /tmp/springboot_package
        cp "$IMAGES_DIR/temurin-jdk8.tar" /tmp/springboot_package/
        cp "$IMAGES_DIR/tomcat9-jdk8.tar" /tmp/springboot_package/
        tar -czf "$PACKAGES_DIR/springboot.tar.gz" -C /tmp springboot_package
        rm -rf /tmp/springboot_package
    }
    echo -e "${GREEN}✓ 完成${NC}"
else
    echo -e "${YELLOW}! 跳过（文件不存在）${NC}"
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}打包完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "打包文件位于: $PACKAGES_DIR/"
echo ""
echo "文件列表:"
ls -lh "$PACKAGES_DIR/" 2>/dev/null || echo "无文件"
echo ""
echo "这些文件可以上传到 GitHub Release 供用户下载"


#!/bin/bash

# Docker 镜像导出脚本
# 用于导出 AMD64 架构的离线镜像包

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 导出目录
EXPORT_DIR="./images"
mkdir -p "$EXPORT_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Docker 镜像导出工具${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}错误: Docker 服务未运行${NC}"
    exit 1
fi

# 定义镜像列表
# 格式: "镜像名|输出文件名"
IMAGES=(
    "openresty/openresty:1.25.3.1-alpine|openresty"
    "redis:7.2|redis"
    "oliver006/redis_exporter:v1.55.0|redis-exporter"
    "mysql:8.0.35|mysql"
    "prom/mysqld-exporter:v0.15.0|mysqld-exporter"
    "prom/prometheus:v2.45.0|prometheus"
    "prom/node-exporter:v1.6.0|node-exporter"
    "grafana/grafana:10.0.0|grafana"
    "eclipse-temurin:8-jdk-alpine|temurin-jdk8"
    "tomcat:9-jdk8|tomcat9-jdk8"
)

# 统计
total=${#IMAGES[@]}
current=0
success=0
failed=0

# 导出镜像
for item in "${IMAGES[@]}"; do
    current=$((current + 1))
    
    # 分割镜像名和文件名
    image=$(echo "$item" | cut -d'|' -f1)
    filename=$(echo "$item" | cut -d'|' -f2)
    output_file="$EXPORT_DIR/${filename}.tar"
    
    echo -e "${YELLOW}[$current/$total] 处理镜像: ${image}${NC}"
    
    # 检查镜像是否存在
    if ! docker image inspect "$image" > /dev/null 2>&1; then
        echo -e "  ${YELLOW}镜像不存在，正在拉取...${NC}"
        if docker pull --platform linux/amd64 "$image"; then
            echo -e "  ${GREEN}✓ 拉取成功${NC}"
        else
            echo -e "  ${RED}✗ 拉取失败${NC}"
            failed=$((failed + 1))
            continue
        fi
    else
        echo -e "  ${GREEN}✓ 镜像已存在${NC}"
    fi
    
    # 导出镜像
    echo -e "  导出到: ${output_file}"
    if docker save "$image" -o "$output_file"; then
        # 获取文件大小
        size=$(du -h "$output_file" | cut -f1)
        echo -e "  ${GREEN}✓ 导出成功 (${size})${NC}"
        success=$((success + 1))
    else
        echo -e "  ${RED}✗ 导出失败${NC}"
        failed=$((failed + 1))
    fi
    
    echo ""
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}导出完成！${NC}"
echo -e "总计: ${total} 个镜像"
echo -e "${GREEN}成功: ${success} 个${NC}"
if [ $failed -gt 0 ]; then
    echo -e "${RED}失败: ${failed} 个${NC}"
fi
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "导出的镜像文件位于: ${EXPORT_DIR}/"
echo -e "可以使用以下命令查看文件列表:"
echo -e "  ls -lh ${EXPORT_DIR}/"
echo ""
echo -e "提示: 这些文件可以上传到 GitHub Release 或其他文件服务器"

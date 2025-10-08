#!/bin/bash
# LanDeployer 镜像加载脚本

IMAGES_DIR="/opt/offline/images"

echo "========================================="
echo "  LanDeployer 镜像加载脚本"
echo "========================================="
echo ""

if [ ! -d "$IMAGES_DIR" ]; then
    echo "错误: 镜像目录不存在: $IMAGES_DIR"
    exit 1
fi

cd "$IMAGES_DIR" || exit 1

# 统计tar文件数量
TAR_COUNT=$(ls -1 *.tar 2>/dev/null | wc -l)

if [ "$TAR_COUNT" -eq 0 ]; then
    echo "警告: 未找到任何.tar镜像文件"
    exit 0
fi

echo "发现 $TAR_COUNT 个镜像文件，开始加载..."
echo ""

SUCCESS=0
FAILED=0

for TAR_FILE in *.tar; do
    echo "正在加载: $TAR_FILE"
    
    if docker load -i "$TAR_FILE"; then
        echo "✓ $TAR_FILE 加载成功"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "✗ $TAR_FILE 加载失败"
        FAILED=$((FAILED + 1))
    fi
    echo ""
done

echo "========================================="
echo "加载完成!"
echo "成功: $SUCCESS"
echo "失败: $FAILED"
echo "========================================="

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi

exit 0


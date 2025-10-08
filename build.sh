#!/bin/bash
# LanDeployer 一键构建脚本

set -e

echo "========================================="
echo "  LanDeployer 构建脚本"
echo "========================================="
echo ""

# 检查Node.js
if ! command -v node &> /dev/null; then
    echo "错误: Node.js 未安装"
    exit 1
fi

# 检查Maven
if ! command -v mvn &> /dev/null; then
    echo "错误: Maven 未安装"
    exit 1
fi

echo "✓ 环境检查通过"
echo ""

# 构建前端
echo "========================================="
echo "1. 构建前端..."
echo "========================================="

cd landeployer-ui

if [ ! -d "node_modules" ]; then
    echo "安装前端依赖..."
    npm install
fi

echo "打包前端..."
npm run build

echo "✓ 前端构建完成"
echo ""

# 构建后端
echo "========================================="
echo "2. 构建后端..."
echo "========================================="

cd ../landeployer-server

echo "编译后端..."
mvn clean package -DskipTests

echo "✓ 后端构建完成"
echo ""

# 输出结果
echo "========================================="
echo "构建完成！"
echo "========================================="
echo ""
echo "生成文件："
echo "  landeployer-server/target/landeployer.jar"
echo ""
echo "运行方法："
echo "  java -jar landeployer-server/target/landeployer.jar"
echo ""
echo "或者："
echo "  cd landeployer-server/target"
echo "  java -jar landeployer.jar"
echo ""
echo "访问地址: http://localhost:8080"
echo "默认账号: admin / admin123"
echo "========================================="


#!/bin/bash
# 构建包含JRE的独立部署包
# 生成的包可以在没有Java环境的机器上直接运行

set -e

echo "========================================="
echo "  构建独立部署包（包含JRE）"
echo "========================================="
echo ""

# 配置
JRE_VERSION="17"
APP_VERSION="1.0.0"
OUTPUT_DIR="dist"
PACKAGE_NAME="landeployer-standalone-v${APP_VERSION}"

# 1. 构建项目
echo "1. 构建项目..."
bash build.sh

# 2. 创建输出目录
echo ""
echo "2. 准备输出目录..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/$PACKAGE_NAME"

# 3. 复制jar包
echo ""
echo "3. 复制应用文件..."
cp landeployer-server/target/landeployer.jar "$OUTPUT_DIR/$PACKAGE_NAME/"
mkdir -p "$OUTPUT_DIR/$PACKAGE_NAME"/{data,logs,storage}

# 4. 使用jlink创建精简JRE
echo ""
echo "4. 创建精简JRE..."
echo "   (需要本地安装JDK 17+)"

if command -v jlink &> /dev/null; then
    # 分析jar包依赖的模块
    MODULES=$(jdeps --print-module-deps --ignore-missing-deps landeployer-server/target/landeployer.jar)
    
    # 添加必要的模块
    MODULES="$MODULES,jdk.crypto.ec,jdk.localedata"
    
    echo "   需要的模块: $MODULES"
    
    # 创建精简JRE
    jlink \
        --add-modules "$MODULES" \
        --strip-debug \
        --no-header-files \
        --no-man-pages \
        --compress=2 \
        --output "$OUTPUT_DIR/$PACKAGE_NAME/jre"
    
    echo "   ✓ JRE创建完成"
    
    # 创建启动脚本（使用内嵌JRE）
    cat > "$OUTPUT_DIR/$PACKAGE_NAME/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
mkdir -p data logs storage
./jre/bin/java -jar landeployer.jar
EOF
    
    cat > "$OUTPUT_DIR/$PACKAGE_NAME/start.bat" << 'EOF'
@echo off
cd /d %~dp0
if not exist data mkdir data
if not exist logs mkdir logs
if not exist storage mkdir storage
jre\bin\java.exe -jar landeployer.jar
pause
EOF
    
else
    echo "   警告: 未找到jlink命令"
    echo "   将创建不含JRE的部署包"
    echo "   目标机器需要安装Java 17+"
    
    # 创建启动脚本（使用系统Java）
    cat > "$OUTPUT_DIR/$PACKAGE_NAME/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
mkdir -p data logs storage

if ! command -v java &> /dev/null; then
    echo "错误: 未找到Java环境"
    echo "请安装Java 17或以上版本"
    exit 1
fi

java -jar landeployer.jar
EOF
    
    cat > "$OUTPUT_DIR/$PACKAGE_NAME/start.bat" << 'EOF'
@echo off
cd /d %~dp0
if not exist data mkdir data
if not exist logs mkdir logs
if not exist storage mkdir storage

where java >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: 未找到Java环境
    echo 请安装Java 17或以上版本
    pause
    exit /b 1
)

java -jar landeployer.jar
pause
EOF
fi

# 设置执行权限
chmod +x "$OUTPUT_DIR/$PACKAGE_NAME/start.sh"

# 5. 复制文档
echo ""
echo "5. 复制文档..."
cp README.md "$OUTPUT_DIR/$PACKAGE_NAME/"
cp INSTALL.md "$OUTPUT_DIR/$PACKAGE_NAME/"

# 创建快速开始文档
cat > "$OUTPUT_DIR/$PACKAGE_NAME/快速开始.txt" << 'EOF'
LanDeployer 快速开始
===================

1. 启动应用

   Linux/Mac:
   $ ./start.sh

   Windows:
   双击 start.bat

2. 访问界面

   打开浏览器访问: http://localhost:8080
   默认账号: admin
   默认密码: admin123

3. 使用步骤

   a) 添加服务器（服务器管理）
   b) 查看支持的服务（资源仓库）
   c) 创建部署任务（部署任务）
   d) 查看任务进度（任务历史）

4. 详细文档

   请查看 README.md 和 INSTALL.md

5. 目录说明

   data/    - 数据库文件
   logs/    - 日志文件
   storage/ - 上传文件存储
   jre/     - Java运行环境（如有）

6. 停止应用

   按 Ctrl+C 或关闭窗口
EOF

# 6. 打包
echo ""
echo "6. 打包..."
cd "$OUTPUT_DIR"
tar czf "${PACKAGE_NAME}-linux.tar.gz" "$PACKAGE_NAME"
zip -rq "${PACKAGE_NAME}-windows.zip" "$PACKAGE_NAME"

cd ..

# 7. 输出信息
echo ""
echo "========================================="
echo "构建完成！"
echo "========================================="
echo ""
echo "生成的文件："
echo "  $OUTPUT_DIR/${PACKAGE_NAME}-linux.tar.gz   (Linux/Mac用)"
echo "  $OUTPUT_DIR/${PACKAGE_NAME}-windows.zip    (Windows用)"
echo ""
echo "目录结构："
ls -lh "$OUTPUT_DIR/$PACKAGE_NAME"
echo ""

if [ -d "$OUTPUT_DIR/$PACKAGE_NAME/jre" ]; then
    JRE_SIZE=$(du -sh "$OUTPUT_DIR/$PACKAGE_NAME/jre" | cut -f1)
    echo "✓ 包含精简JRE (大小: $JRE_SIZE)"
    echo "  可在无Java环境的机器上直接运行"
else
    echo "⚠ 未包含JRE"
    echo "  目标机器需要安装Java 17+"
fi

echo ""
echo "使用方法："
echo "  1. 将压缩包拷贝到目标机器"
echo "  2. 解压"
echo "  3. 运行 start.sh (Linux/Mac) 或 start.bat (Windows)"
echo "  4. 访问 http://localhost:8080"
echo "========================================="

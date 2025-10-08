#!/bin/bash
# LanDeployer 自带JRE运行脚本
# 此脚本会自动下载JRE并运行应用，无需预装Java

set -e

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
JRE_DIR="$APP_DIR/jre"
JAR_FILE="$APP_DIR/landeployer-server/target/landeployer.jar"
JRE_VERSION="17"

echo "========================================="
echo "  LanDeployer 启动脚本"
echo "========================================="
echo ""

# 检查jar文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "错误: 未找到 $JAR_FILE"
    echo "请先运行 build.sh 构建项目"
    exit 1
fi

# 检测操作系统和架构
detect_platform() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case "$OS" in
        linux*)
            OS="linux"
            ;;
        darwin*)
            OS="mac"
            ;;
        mingw*|msys*|cygwin*)
            OS="windows"
            ;;
        *)
            echo "不支持的操作系统: $OS"
            exit 1
            ;;
    esac
    
    case "$ARCH" in
        x86_64|amd64)
            ARCH="x64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        *)
            echo "不支持的架构: $ARCH"
            exit 1
            ;;
    esac
    
    echo "检测到平台: $OS-$ARCH"
}

# 下载JRE
download_jre() {
    echo ""
    echo "正在下载JRE $JRE_VERSION for $OS-$ARCH..."
    echo "这可能需要几分钟，请耐心等待..."
    echo ""
    
    # 使用Adoptium（原AdoptOpenJDK）
    if [ "$OS" = "linux" ]; then
        JRE_URL="https://github.com/adoptium/temurin${JRE_VERSION}-binaries/releases/download/jdk-${JRE_VERSION}.0.9%2B9/OpenJDK${JRE_VERSION}U-jre_${ARCH}_${OS}_hotspot_${JRE_VERSION}.0.9_9.tar.gz"
        JRE_ARCHIVE="jre.tar.gz"
    elif [ "$OS" = "mac" ]; then
        JRE_URL="https://github.com/adoptium/temurin${JRE_VERSION}-binaries/releases/download/jdk-${JRE_VERSION}.0.9%2B9/OpenJDK${JRE_VERSION}U-jre_${ARCH}_mac_hotspot_${JRE_VERSION}.0.9_9.tar.gz"
        JRE_ARCHIVE="jre.tar.gz"
    elif [ "$OS" = "windows" ]; then
        JRE_URL="https://github.com/adoptium/temurin${JRE_VERSION}-binaries/releases/download/jdk-${JRE_VERSION}.0.9%2B9/OpenJDK${JRE_VERSION}U-jre_${ARCH}_windows_hotspot_${JRE_VERSION}.0.9_9.zip"
        JRE_ARCHIVE="jre.zip"
    fi
    
    # 创建临时目录
    TMP_DIR=$(mktemp -d)
    
    # 下载
    if command -v wget &> /dev/null; then
        wget -O "$TMP_DIR/$JRE_ARCHIVE" "$JRE_URL"
    elif command -v curl &> /dev/null; then
        curl -L -o "$TMP_DIR/$JRE_ARCHIVE" "$JRE_URL"
    else
        echo "错误: 需要 wget 或 curl 来下载JRE"
        echo "请手动安装Java 17或以上版本"
        exit 1
    fi
    
    # 解压
    echo "正在解压JRE..."
    mkdir -p "$JRE_DIR"
    
    if [ "$OS" = "windows" ]; then
        unzip -q "$TMP_DIR/$JRE_ARCHIVE" -d "$JRE_DIR"
    else
        tar -xzf "$TMP_DIR/$JRE_ARCHIVE" -C "$JRE_DIR" --strip-components=1
    fi
    
    # 清理临时文件
    rm -rf "$TMP_DIR"
    
    echo "✓ JRE下载并安装完成"
}

# 检查Java
check_java() {
    # 优先使用自带JRE
    if [ -d "$JRE_DIR" ]; then
        if [ "$OS" = "windows" ]; then
            JAVA_CMD="$JRE_DIR/bin/java.exe"
        else
            JAVA_CMD="$JRE_DIR/bin/java"
        fi
        
        if [ -x "$JAVA_CMD" ]; then
            echo "使用自带JRE: $JAVA_CMD"
            return 0
        fi
    fi
    
    # 检查系统Java
    if command -v java &> /dev/null; then
        JAVA_CMD="java"
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        
        if [ "$JAVA_VERSION" -ge 17 ]; then
            echo "使用系统Java: $(which java)"
            return 0
        else
            echo "系统Java版本过低: $JAVA_VERSION (需要17+)"
        fi
    fi
    
    return 1
}

# 主流程
main() {
    detect_platform
    
    echo ""
    echo "检查Java环境..."
    
    if ! check_java; then
        echo ""
        echo "未找到合适的Java环境"
        echo ""
        read -p "是否自动下载JRE? (y/n) " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            download_jre
            
            # 重新检查
            if ! check_java; then
                echo "错误: JRE安装失败"
                exit 1
            fi
        else
            echo "请手动安装Java 17或以上版本"
            exit 1
        fi
    fi
    
    echo ""
    echo "========================================="
    echo "启动 LanDeployer..."
    echo "========================================="
    echo ""
    
    # 创建必要的目录
    mkdir -p "$APP_DIR/data" "$APP_DIR/logs" "$APP_DIR/storage"
    
    # 启动应用
    cd "$APP_DIR"
    "$JAVA_CMD" -jar "$JAR_FILE"
}

main

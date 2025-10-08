#!/bin/bash
# LanDeployer Python版本构建脚本
# 使用PyInstaller打包成包含Python环境的独立可执行文件

set -e

echo "========================================="
echo "  LanDeployer Python版本构建"
echo "========================================="
echo ""

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "错误: Python3未安装"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}' | cut -d. -f1-2)
echo "Python版本: $PYTHON_VERSION"

# 检查是否在虚拟环境中
if [ -z "$VIRTUAL_ENV" ]; then
    echo ""
    echo "建议使用虚拟环境，正在创建..."
    python3 -m venv venv
    source venv/bin/activate
    echo "✓ 虚拟环境已激活"
fi

echo ""
echo "1. 安装依赖..."
echo "========================================="
cd landeployer-backend
pip install -r requirements.txt
pip install pyinstaller

echo ""
echo "2. 构建前端..."
echo "========================================="
cd ../landeployer-ui

if [ ! -d "node_modules" ]; then
    npm install
fi

npm run build

echo ""
echo "3. 使用PyInstaller打包..."
echo "========================================="
cd ../landeployer-backend

# 创建spec文件
cat > landeployer.spec << 'EOF'
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['run.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('static', 'static'),
    ],
    hiddenimports=[
        'uvicorn.logging',
        'uvicorn.loops',
        'uvicorn.loops.auto',
        'uvicorn.protocols',
        'uvicorn.protocols.http',
        'uvicorn.protocols.http.auto',
        'uvicorn.protocols.websockets',
        'uvicorn.protocols.websockets.auto',
        'uvicorn.lifespan',
        'uvicorn.lifespan.on',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='landeployer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
EOF

# 执行打包
pyinstaller landeployer.spec --clean

echo ""
echo "4. 整理输出文件..."
echo "========================================="
cd ..

# 创建发布目录
rm -rf dist/landeployer-release
mkdir -p dist/landeployer-release
mkdir -p dist/landeployer-release/{data,logs,storage}

# 复制可执行文件
cp landeployer-backend/dist/landeployer dist/landeployer-release/

# 创建启动脚本
cat > dist/landeployer-release/start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
mkdir -p data logs storage
./landeployer
EOF

chmod +x dist/landeployer-release/start.sh
chmod +x dist/landeployer-release/landeployer

# 复制文档
cp README.md dist/landeployer-release/ 2>/dev/null || true
cp scripts -r dist/landeployer-release/ 2>/dev/null || true

# 打包
cd dist
tar czf landeployer-python-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz landeployer-release

echo ""
echo "========================================="
echo "构建完成！"
echo "========================================="
echo ""
echo "生成文件："
echo "  dist/landeployer-release/landeployer  (可执行文件，包含Python环境)"
echo "  dist/landeployer-python-*.tar.gz      (压缩包)"
echo ""
echo "文件大小："
ls -lh landeployer-python-*.tar.gz
echo ""
echo "运行方法："
echo "  cd dist/landeployer-release"
echo "  ./start.sh"
echo ""
echo "或直接运行："
echo "  ./dist/landeployer-release/landeployer"
echo ""
echo "特点："
echo "  ✓ 包含Python运行环境"
echo "  ✓ 无需安装Python"
echo "  ✓ 单文件可执行"
echo "  ✓ 支持离线运行"
echo "========================================="


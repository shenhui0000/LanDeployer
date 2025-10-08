@echo off
REM LanDeployer Windows版本构建脚本
REM 使用PyInstaller打包成包含Python环境的独立可执行文件

echo =========================================
echo   LanDeployer Windows版本构建
echo =========================================
echo.

REM 检查Python
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Python未安装或未添加到PATH
    pause
    exit /b 1
)

REM 检查Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Node.js未安装或未添加到PATH
    pause
    exit /b 1
)

echo Python版本:
python --version
echo Node.js版本:
node --version
echo.

REM 创建虚拟环境
echo 1. 创建虚拟环境...
python -m venv venv
call venv\Scripts\activate.bat

echo.
echo 2. 安装Python依赖...
cd landeployer-backend
pip install -r requirements.txt
pip install pyinstaller

echo.
echo 3. 构建前端...
cd ..\landeployer-ui

REM 检查node_modules是否存在
if not exist "node_modules" (
    echo 安装Node.js依赖...
    npm install
)

echo 构建前端...
npm run build

echo.
echo 4. 使用PyInstaller打包...
cd ..\landeployer-backend

REM 创建spec文件
echo 创建PyInstaller配置文件...
(
echo # -*- mode: python ; coding: utf-8 -*-
echo.
echo block_cipher = None
echo.
echo a = Analysis^(
echo     ['run.py'],
echo     pathex=[],
echo     binaries=[],
echo     datas=[
echo         ^('static', 'static'^),
echo         ^('data', 'data'^),
echo     ],
echo     hiddenimports=[
echo         'uvicorn.logging',
echo         'uvicorn.loops',
echo         'uvicorn.loops.auto',
echo         'uvicorn.protocols',
echo         'uvicorn.protocols.http',
echo         'uvicorn.protocols.http.auto',
echo         'uvicorn.protocols.websockets',
echo         'uvicorn.protocols.websockets.auto',
echo         'uvicorn.lifespan',
echo         'uvicorn.lifespan.on',
echo         'app',
echo         'app.main',
echo         'app.config',
echo         'app.database',
echo         'app.models',
echo         'app.schemas',
echo         'app.routers',
echo         'app.routers.hosts',
echo         'app.routers.roles',
echo         'app.routers.deploy',
echo         'app.services',
echo         'app.services.ssh_service',
echo         'app.services.role_service',
echo     ],
echo     hookspath=[],
echo     hooksconfig={},
echo     runtime_hooks=[],
echo     excludes=[],
echo     win_no_prefer_redirects=False,
echo     win_private_assemblies=False,
echo     cipher=block_cipher,
echo     noarchive=False,
echo ^)
echo.
echo pyz = PYZ^(a.pure, a.zipped_data, cipher=block_cipher^)
echo.
echo exe = EXE^(
echo     pyz,
echo     a.scripts,
echo     a.binaries,
echo     a.zipfiles,
echo     a.datas,
echo     [],
echo     name='landeployer',
echo     debug=False,
echo     bootloader_ignore_signals=False,
echo     strip=False,
echo     upx=True,
echo     upx_exclude=[],
echo     runtime_tmpdir=None,
echo     console=True,
echo     disable_windowed_traceback=False,
echo     argv_emulation=False,
echo     target_arch=None,
echo     codesign_identity=None,
echo     entitlements_file=None,
echo ^)
) > landeployer.spec

REM 执行打包
pyinstaller landeployer.spec --clean

echo.
echo 5. 整理输出文件...
cd ..

REM 创建发布目录
if exist "dist\landeployer-release" rmdir /s /q "dist\landeployer-release"
mkdir "dist\landeployer-release"
mkdir "dist\landeployer-release\data"
mkdir "dist\landeployer-release\logs"
mkdir "dist\landeployer-release\storage"
mkdir "dist\landeployer-release\scripts"

REM 复制可执行文件
copy "landeployer-backend\dist\landeployer.exe" "dist\landeployer-release\"
copy "README.md" "dist\landeployer-release\"
xcopy "scripts" "dist\landeployer-release\scripts\" /E /I

REM 创建启动脚本
echo @echo off > "dist\landeployer-release\start.bat"
echo cd /d "%%~dp0" >> "dist\landeployer-release\start.bat"
echo if not exist "data" mkdir data >> "dist\landeployer-release\start.bat"
echo if not exist "logs" mkdir logs >> "dist\landeployer-release\start.bat"
echo if not exist "storage" mkdir storage >> "dist\landeployer-release\start.bat"
echo landeployer.exe >> "dist\landeployer-release\start.bat"

REM 创建压缩包
cd dist
powershell Compress-Archive -Path landeployer-release -DestinationPath landeployer-python-windows-x86_64.zip -Force

echo.
echo =========================================
echo 构建完成！
echo =========================================
echo.
echo 生成文件：
echo   dist\landeployer-release\landeployer.exe  (可执行文件，包含Python环境)
echo   dist\landeployer-python-windows-x86_64.zip  (压缩包)
echo.
echo 文件大小：
for %%F in (landeployer-python-windows-x86_64.zip) do echo   %%~nxF: %%~zF bytes
echo.
echo 运行方法：
echo   cd dist\landeployer-release
echo   start.bat
echo.
echo 或直接运行：
echo   dist\landeployer-release\landeployer.exe
echo.
echo 特点：
echo   ✓ 包含Python运行环境
echo   ✓ 无需安装Python
echo   ✓ 单文件可执行
echo   ✓ 支持离线运行
echo =========================================

pause

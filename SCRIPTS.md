# 脚本使用指南

本文档详细说明项目中各个脚本的用途、执行时机和使用方法。

## 📋 脚本概览

| 脚本 | 用途 | 执行时机 | 输入 | 输出 |
|------|------|----------|------|------|
| `build-python.sh` | 构建可执行程序 | 需要分发程序时 | 源码 | 可执行文件 |
| `export-images.sh` | 导出Docker镜像 | 准备离线镜像时 | 无 | 镜像tar文件 |
| `package-images.sh` | 打包镜像文件 | 整理镜像时 | 镜像tar文件 | 打包文件 |
| `create-release.sh` | 创建GitHub Release | 发布新版本时 | 所有文件 | GitHub Release |

---

## 🔨 构建脚本

### build-python.sh

**用途**: 将Python项目打包成包含Python环境的单文件可执行程序

**执行时机**: 
- 需要分发程序给其他用户时
- 准备发布新版本时
- 需要零依赖部署时

**使用方法**:
```bash
# 在项目根目录执行
./build-python.sh
```

**执行过程**:
1. 检查Python环境
2. 创建虚拟环境（如果不存在）
3. 安装Python依赖
4. 构建前端（Vue项目）
5. 使用PyInstaller打包
6. 整理输出文件
7. 创建压缩包

**输出文件**:
- `dist/landeployer-release/landeployer` - 可执行文件（约16MB）
- `dist/landeployer-python-*.tar.gz` - 发布压缩包（约15MB）

**特点**:
- ✅ 包含完整Python环境
- ✅ 包含所有依赖库
- ✅ 包含前端静态文件
- ✅ 单文件可执行
- ✅ 支持离线运行

---

## 🐳 Docker镜像脚本

### export-images.sh

**用途**: 拉取并导出所有需要的Docker镜像为tar文件

**执行时机**:
- 准备离线部署环境时
- 需要更新镜像版本时
- 首次设置项目时

**使用方法**:
```bash
# 在有外网的机器上执行
./export-images.sh
```

**执行过程**:
1. 检查Docker是否运行
2. 拉取所有需要的镜像（如果本地没有）
3. 导出镜像为tar文件
4. 显示导出结果

**导出的镜像**:
- openresty/openresty:1.25.3.1-alpine
- redis:7.2
- oliver006/redis_exporter:v1.55.0
- mysql:8.0.35
- prom/mysqld-exporter:v0.15.0
- prom/prometheus:v2.45.0
- prom/node-exporter:v1.6.0
- grafana/grafana:10.0.0
- eclipse-temurin:8-jdk-alpine
- tomcat:9-jdk8

**输出文件**:
- `images/openresty.tar` (102MB)
- `images/redis.tar` (114MB)
- `images/redis-exporter.tar` (9.2MB)
- `images/mysql.tar` (579MB)
- `images/mysqld-exporter.tar` (20MB)
- `images/prometheus.tar` (227MB)
- `images/node-exporter.tar` (23MB)
- `images/grafana.tar` (318MB)
- `images/temurin-jdk8.tar` (184MB)
- `images/tomcat9-jdk8.tar` (293MB)

**总计大小**: 约1.8GB

### package-images.sh

**用途**: 将相关的Docker镜像打包到一起，方便分发

**执行时机**:
- 整理镜像文件时
- 准备分发包时
- 优化下载体验时

**使用方法**:
```bash
# 在项目根目录执行（需要先运行export-images.sh）
./package-images.sh
```

**执行过程**:
1. 检查images目录是否存在
2. 将相关镜像打包到一起
3. 创建压缩包

**输出文件**:
- `packages/openresty.tar.gz` - OpenResty镜像包
- `packages/redis.tar.gz` - Redis + Exporter镜像包
- `packages/mysql.tar.gz` - MySQL + Exporter镜像包
- `packages/prometheus.tar.gz` - Prometheus + Node Exporter镜像包
- `packages/grafana.tar.gz` - Grafana镜像包
- `packages/springboot.tar.gz` - SpringBoot相关镜像包

---

## 🚀 发布脚本

### create-release.sh

**用途**: 自动创建GitHub Release并上传所有文件

**执行时机**:
- 发布新版本时
- 需要分享文件时
- 正式发布项目时

**使用方法**:
```bash
# 1. 先登录GitHub CLI
gh auth login

# 2. 创建Release
./create-release.sh
```

**执行过程**:
1. 检查GitHub CLI登录状态
2. 检查必要文件是否存在
3. 创建GitHub Release
4. 上传可执行程序和镜像文件
5. 显示发布结果

**上传文件**:
- `dist/landeployer-python-*.tar.gz` - 可执行程序
- `images/*.tar` - 所有Docker镜像文件

**前置条件**:
- 已安装GitHub CLI (`brew install gh`)
- 已登录GitHub (`gh auth login`)
- 已运行`build-python.sh`和`export-images.sh`

---

## 🔄 完整工作流程

### 开发阶段

```bash
# 1. 开发代码
# 修改后端代码
# 修改前端代码

# 2. 本地测试
cd landeployer-backend
python run.py
```

### 构建阶段

```bash
# 1. 构建可执行程序
./build-python.sh

# 2. 导出Docker镜像（在有外网的机器上）
./export-images.sh

# 3. （可选）打包镜像
./package-images.sh
```

### 发布阶段

```bash
# 1. 提交代码到Git
git add .
git commit -m "发布v1.0.0"
git push origin main

# 2. 创建GitHub Release
gh auth login  # 如果未登录
./create-release.sh
```

### 部署阶段

```bash
# 1. 下载发布包
wget https://github.com/shenhui0000/LanDeployer/releases/download/v1.0.0/landeployer-python-darwin-arm64.tar.gz

# 2. 解压并运行
tar xzf landeployer-python-darwin-arm64.tar.gz
cd landeployer-release
./start.sh

# 3. 下载并导入镜像
wget https://github.com/shenhui0000/LanDeployer/releases/download/v1.0.0/openresty.tar
docker load -i openresty.tar
```

---

## ⚠️ 注意事项

### 环境要求

- **build-python.sh**: 需要Python 3.8+、Node.js 16+、Docker
- **export-images.sh**: 需要Docker、外网连接
- **package-images.sh**: 需要先运行export-images.sh
- **create-release.sh**: 需要GitHub CLI、已登录GitHub

### 文件大小

- 可执行程序: ~16MB
- 单个镜像: 9MB - 579MB
- 所有镜像: ~1.8GB
- GitHub Release限制: 单个文件最大2GB

### 网络要求

- **export-images.sh**: 需要外网连接拉取镜像
- **create-release.sh**: 需要外网连接上传文件
- 其他脚本: 可在离线环境运行

### 权限要求

- 所有脚本需要执行权限: `chmod +x *.sh`
- create-release.sh需要GitHub仓库的写权限

---

## 🛠️ 故障排除

### 常见错误

1. **Docker未运行**
   ```bash
   # 启动Docker
   open -a Docker  # macOS
   sudo systemctl start docker  # Linux
   ```

2. **GitHub CLI未登录**
   ```bash
   gh auth login
   ```

3. **权限不足**
   ```bash
   chmod +x *.sh
   ```

4. **磁盘空间不足**
   ```bash
   # 检查空间
   df -h
   # 清理不需要的文件
   ```

### 调试模式

```bash
# 查看详细输出
bash -x build-python.sh

# 查看错误日志
./build-python.sh 2>&1 | tee build.log
```

---

## 📚 相关文档

- [README.md](README.md) - 项目主要文档
- [docs/index.html](docs/index.html) - 项目官网
- [landeployer-backend/requirements.txt](landeployer-backend/requirements.txt) - Python依赖
- [landeployer-ui/package.json](landeployer-ui/package.json) - 前端依赖

---

**提示**: 建议按照脚本的执行顺序使用，确保每个步骤都成功完成后再进行下一步。

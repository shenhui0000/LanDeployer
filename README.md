# LanDeployer - 离线内网部署工具

LanDeployer 是一个专为内网环境设计的可视化部署工具，支持通过Web界面快速部署OpenResty、MySQL、Redis、Prometheus、Grafana等服务。

**特点：使用Python开发，打包后自带Python环境，无需任何依赖！**

## ✨ 核心特性

- 🌐 **Web可视化界面** - 基于Vue3 + Element Plus，操作简单直观
- 🔒 **完全离线部署** - 无需外网，所有资源可提前准备
- 🚀 **一键部署** - 4步完成服务部署，自动化程度高
- 📦 **资源管理** - 智能检测缺失的镜像包和配置文件
- 📊 **实时监控** - 内置Prometheus + Grafana监控方案
- 🖥️ **多机支持** - 可管理多台服务器，灵活选择部署目标
- 📝 **任务追踪** - 完整的部署日志和任务历史
- 🐍 **Python开发** - 轻量级，打包后自带Python环境

## 🏗️ 技术栈

**后端:**
- Python 3.8+
- FastAPI (高性能Web框架)
- SQLAlchemy (ORM)
- Paramiko (SSH连接)
- SQLite (轻量级数据库)

**前端:**
- Vue 3
- Element Plus
- Vite

**打包:**
- PyInstaller (打包成包含Python环境的可执行文件)

**支持的服务:**
- OpenResty (高性能Web平台)
- MySQL 8.0 (关系型数据库)
- Redis 7.2 (缓存数据库)
- Prometheus (监控系统)
- Grafana (可视化面板)
- SpringBoot (Java应用)
- Node Exporter (节点监控)

## 🚀 快速开始

### 方式1: 下载预编译版本（推荐，零依赖）✨

**无需安装Python！开箱即用！**

```bash
# 1. 下载对应系统的压缩包
# landeployer-python-darwin-arm64.tar.gz (macOS Apple Silicon)
# landeployer-python-darwin-x86_64.tar.gz (macOS Intel)
# landeployer-python-linux-x86_64.tar.gz (Linux)

# 2. 解压
tar xzf landeployer-python-*.tar.gz
cd landeployer-release

# 3. 运行
./start.sh

# 访问 http://localhost:8080
# 默认账号: admin / admin123
```

**特点:**
- ✅ 无需安装Python
- ✅ 无需安装任何依赖
- ✅ 解压即用
- ✅ 包含完整Python运行环境
- ✅ 单文件可执行（约16MB）

---

### 方式2: 从源码构建

#### 环境要求

**必需:**
- Python 3.8+
- Node.js 16+ (用于前端构建)
- pip

**可选:**
- virtualenv (推荐使用虚拟环境)

#### 构建步骤

```bash
# 1. 克隆项目
git clone https://github.com/shenhui0000/LanDeployer.git
cd LanDeployer

# 2. 一键构建（自动打包成包含Python环境的可执行文件）
bash build-python.sh

# 构建完成后生成：
# - dist/landeployer-release/landeployer (可执行文件)
# - dist/landeployer-python-*.tar.gz (压缩包)

# 3. 运行
cd dist/landeployer-release
./start.sh
```

#### 开发模式运行

```bash
# 1. 创建虚拟环境（推荐）
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. 安装依赖
cd landeployer-backend
pip install -r requirements.txt

# 3. 构建前端
cd ../landeployer-ui
npm install
npm run build

# 4. 运行
cd ../landeployer-backend
python run.py

# 访问 http://localhost:8080
```

---

## 📦 使用流程

### 1. 添加服务器

进入「服务器管理」页面，添加目标服务器：
- 输入服务器名称、IP、端口
- 配置SSH认证（支持密码和私钥）
- 设置远程部署路径（默认 `/opt/offline`）
- 点击「测试」验证连接

### 2. 准备离线资源

将以下文件上传到服务器的对应目录：

```
/opt/offline/
├── images/          # Docker镜像tar包
│   ├── openresty.tar
│   ├── redis.tar
│   ├── mysql.tar
│   └── ...
├── compose/         # Docker Compose文件
│   ├── openresty.yml
│   ├── redis.yml
│   └── ...
└── config/          # 配置文件
    ├── openresty/
    ├── prometheus/
    └── grafana/
```

**获取镜像tar包:**

```bash
# 在有外网的机器上拉取镜像
docker pull openresty/openresty:1.25.3.1-alpine
docker pull redis:7.2
docker pull mysql:8.0.35
docker pull prom/prometheus:v2.45.0
docker pull grafana/grafana:10.0.0

# 导出为tar包
docker save -o openresty.tar openresty/openresty:1.25.3.1-alpine
docker save -o redis.tar redis:7.2
docker save -o mysql.tar mysql:8.0.35
# ... 其他镜像

# 拷贝到内网服务器
scp *.tar root@<内网IP>:/opt/offline/images/
```

**拷贝配置文件:**

```bash
# 将项目中的scripts目录内容拷贝到服务器
cd LanDeployer/scripts
scp -r compose config load.sh root@<内网IP>:/opt/offline/
```

### 3. 创建部署任务

进入「部署任务」页面：
1. **选择服务器** - 从列表中选择在线的服务器
2. **选择角色** - 勾选需要部署的服务（如OpenResty、Redis等）
3. **检查资源** - 系统自动检查是否缺失镜像包或配置文件
4. **开始部署** - 输入任务名称，点击「开始部署」

### 4. 查看任务进度

部署任务会在后台异步执行，可以在「任务历史」页面查看：
- 实时进度
- 执行日志
- 成功/失败状态

---

## 📂 项目结构

```
LanDeployer/
├── landeployer-backend/        # Python后端
│   ├── app/
│   │   ├── main.py            # 主应用
│   │   ├── config.py          # 配置
│   │   ├── database.py        # 数据库
│   │   ├── models.py          # 数据模型
│   │   ├── schemas.py         # Pydantic模型
│   │   ├── routers/           # 路由
│   │   └── services/          # 服务层
│   ├── run.py                 # 启动文件
│   └── requirements.txt       # Python依赖
├── landeployer-ui/             # Vue前端
│   ├── src/
│   │   ├── views/             # 页面组件
│   │   ├── api/               # API接口
│   │   └── router/            # 路由配置
│   └── package.json
├── scripts/                    # 部署脚本和配置
│   ├── compose/               # Docker Compose文件
│   ├── config/                # 服务配置文件
│   └── load.sh                # 镜像加载脚本
├── docs/                      # 项目官网
│   └── index.html             # GitHub Pages 官网
├── images/                    # Docker镜像文件（不提交到Git）
├── dist/                      # 构建输出（不提交到Git）
├── build-python.sh            # 构建脚本
├── export-images.sh           # 镜像导出脚本
├── package-images.sh          # 镜像打包脚本
├── create-release.sh          # GitHub Release创建脚本
└── README.md
```

---

## 🛠️ 脚本说明

### 构建和打包脚本

| 脚本 | 用途 | 执行时机 | 说明 |
|------|------|----------|------|
| `build-python.sh` | 构建可执行程序 | 需要分发程序时 | 使用PyInstaller打包成单文件可执行程序 |
| `export-images.sh` | 导出Docker镜像 | 准备离线镜像时 | 拉取并导出所有需要的Docker镜像 |
| `package-images.sh` | 打包镜像文件 | 整理镜像时 | 将相关镜像打包到一起，方便分发 |
| `create-release.sh` | 创建GitHub Release | 发布新版本时 | 自动创建GitHub Release并上传文件 |

### 使用示例

```bash
# 1. 开发完成后，构建可执行程序
./build-python.sh

# 2. 准备离线镜像（在有外网的机器上）
./export-images.sh

# 3. （可选）打包镜像
./package-images.sh

# 4. 发布到GitHub（需要先登录 gh auth login）
./create-release.sh
```

---

## 🔧 配置说明

### 环境变量

创建 `.env` 文件（可选）：

```bash
# 服务器配置
HOST=0.0.0.0
PORT=8080
DEBUG=False

# 数据库
DATABASE_URL=sqlite:///./data/landeployer.db

# SSH配置
SSH_TIMEOUT=30
REMOTE_PATH=/opt/offline

# 存储路径
STORAGE_PATH=./storage
```

### 系统预置角色

| 角色 | 镜像 | 端口 | 说明 |
|-----|------|------|------|
| openresty | openresty:1.25.3.1-alpine | 80,443,9145 | 高性能Web平台 |
| redis | redis:7.2 | 6379,9121 | 缓存数据库 |
| mysql | mysql:8.0.35 | 3306,9104 | 关系型数据库 |
| prometheus | prometheus:v2.45.0 | 9090 | 监控系统 |
| grafana | grafana:10.0.0 | 3000 | 可视化面板 |
| springboot | eclipse-temurin:8 | 8080,8081 | Java应用 |
| node-exporter | node-exporter:v1.6.0 | 9100 | 节点监控 |

---

## 🌐 项目官网

项目官网：https://shenhui0000.github.io/LanDeployer/

官网包含：
- 功能特性介绍
- 支持服务列表
- 下载链接
- 快速开始指南

---

## 📦 Docker 镜像

### 镜像列表（AMD64 架构）

| 镜像文件 | 大小 | 说明 |
|---------|------|------|
| openresty.tar | ~102MB | OpenResty Web 服务器 |
| redis.tar | ~114MB | Redis 缓存数据库 |
| redis-exporter.tar | ~9MB | Redis 监控导出器 |
| mysql.tar | ~579MB | MySQL 8.0.35 数据库 |
| mysqld-exporter.tar | ~20MB | MySQL 监控导出器 |
| prometheus.tar | ~227MB | Prometheus 监控系统 |
| node-exporter.tar | ~23MB | 节点监控导出器 |
| grafana.tar | ~318MB | Grafana 可视化平台 |
| temurin-jdk8.tar | ~184MB | Eclipse Temurin JDK 8 |
| tomcat9-jdk8.tar | ~293MB | Tomcat 9 + JDK 8 |

**总计大小**: 约 1.8GB

### 下载和使用

```bash
# 从 GitHub Release 下载
wget https://github.com/shenhui0000/LanDeployer/releases/download/v1.0.0/openresty.tar

# 导入镜像
docker load -i openresty.tar

# 启动服务
cd /opt/offline
docker-compose -f compose/redis.yml up -d
```

---

## ❓ 常见问题

### Q: 需要安装Python吗？

A: **不需要！** 使用预编译版本或自己构建后，可执行文件已包含完整Python环境。

### Q: 打包后的文件有多大？

A: 约16MB，包含Python运行时、所有依赖库和前端文件。

### Q: 支持哪些操作系统？

A: 
- macOS (Intel / Apple Silicon)
- Linux (x86_64 / ARM64)
- Windows (需要在Windows上构建)

### Q: SSH连接失败？

A: 请检查：
1. 服务器防火墙是否开放SSH端口
2. SSH认证信息是否正确
3. 网络是否连通

### Q: Docker镜像加载失败？

A: 请确保：
1. 目标服务器已安装Docker
2. tar包完整且未损坏
3. 有足够的磁盘空间

---

## 🔄 从Java版本迁移

如果您之前使用的是Java版本，数据库结构保持兼容，只需：

1. 备份数据：`cp data/landeployer.db data/landeployer.db.backup`
2. 停止Java版本
3. 运行Python版本
4. 数据自动迁移

---

## 📝 开发指南

### 运行测试

```bash
cd landeployer-backend
pytest
```

### 代码格式化

```bash
# 安装工具
pip install black flake8

# 格式化代码
black app/
flake8 app/
```

### 添加新的部署角色

编辑 `app/services/role_service.py`，在 `init_default_roles()` 函数中添加新角色。

---

## 📄 许可证

本项目采用 MIT 许可证。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📧 联系方式

如有问题，请通过Issue反馈。

---

**注意**: 本工具专为内网离线环境设计，请确保在安全可控的环境中使用。
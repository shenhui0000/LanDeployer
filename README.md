# LanDeployer - 离线内网部署工具

LanDeployer 是一个专为内网环境设计的可视化部署工具，支持通过Web界面快速部署OpenResty、MySQL、Redis、Prometheus、Grafana等服务。

## ✨ 核心特性

- 🌐 **Web可视化界面** - 基于Vue3 + Element Plus，操作简单直观
- 🔒 **完全离线部署** - 无需外网，所有资源可提前准备
- 🚀 **一键部署** - 4步完成服务部署，自动化程度高
- 📦 **资源管理** - 智能检测缺失的镜像包和配置文件
- 📊 **实时监控** - 内置Prometheus + Grafana监控方案
- 🖥️ **多机支持** - 可管理多台服务器，灵活选择部署目标
- 📝 **任务追踪** - 完整的部署日志和任务历史

## 🏗️ 架构说明

### 技术栈

**后端:**
- Spring Boot 3.2.0
- Spring Data JPA
- SQLite 数据库
- JSch (SSH连接)

**前端:**
- Vue 3
- Element Plus
- Vite

**支持的服务:**
- OpenResty (高性能Web平台)
- MySQL 8.0 (关系型数据库)
- Redis 7.2 (缓存数据库)
- Prometheus (监控系统)
- Grafana (可视化面板)
- SpringBoot (Java应用)
- Node Exporter (节点监控)

## 📦 快速开始

### 方式选择

LanDeployer 提供**4种启动方式**，根据您的环境选择：

| 启动方式 | 是否需要JDK | 包体积 | 适用场景 |
|---------|-----------|--------|---------|
| **Docker部署** | ❌ 不需要 | ~100MB | 生产环境、服务器 |
| **独立包（含JRE）** | ❌ 不需要 | ~120MB | 桌面环境、演示 |
| **自动下载JRE** | ❌ 不需要 | ~50MB | 测试环境 |
| **传统方式** | ✅ 需要 | ~30MB | 已有Java环境 |

> 💡 **推荐**: 生产环境使用Docker，演示环境使用独立包

---

## 🚀 启动模式

### 模式1: Docker部署（推荐，无需JDK）

**优势**: 环境隔离、一键启动、支持离线

```bash
# 1. 构建Docker镜像（包含JRE）
bash build-docker.sh

# 2. 启动容器
docker-compose -f docker-compose-landeployer.yml up -d

# 3. 访问
# http://localhost:8080
# 账号: admin / admin123
```

**离线部署**:
```bash
# 导出镜像
docker save -o landeployer-docker.tar landeployer:latest

# 拷贝到其他机器
scp landeployer-docker.tar user@target:/tmp/

# 在目标机器加载并运行
docker load -i /tmp/landeployer-docker.tar
docker run -d -p 8080:8080 --name landeployer landeployer:latest
```

---

### 模式2: 独立包部署（无需JDK，开箱即用）

**优势**: 解压即用、包含精简JRE、跨平台

```bash
# 1. 构建独立包（仅构建时需要JDK）
bash build-standalone.sh

# 2. 会生成两个压缩包
# - dist/landeployer-standalone-v1.0.0-linux.tar.gz
# - dist/landeployer-standalone-v1.0.0-windows.zip

# 3. 解压并运行
# Linux/Mac:
tar xzf landeployer-standalone-v1.0.0-linux.tar.gz
cd landeployer-standalone-v1.0.0
./start.sh

# Windows:
# 解压后双击 start.bat
```

**包含内容**:
- `landeployer.jar` - 应用程序
- `jre/` - 精简Java运行环境（50-80MB）
- `start.sh` / `start.bat` - 启动脚本
- `data/` `logs/` `storage/` - 数据目录

---

### 模式3: 自动下载JRE（无需JDK，首次自动配置）

**优势**: 首次自动下载JRE、后续无感知、包体积小

```bash
# 1. 构建项目
bash build.sh

# 2. 运行（首次会询问是否下载JRE）
bash run-with-bundled-jre.sh

# 脚本会自动：
# - 检测操作系统和架构
# - 提示下载匹配的JRE（约50-80MB）
# - 下载并安装到 jre/ 目录
# - 启动应用
# - 后续运行直接使用已下载的JRE
```

---

### 模式4: 传统方式（需要JDK 17+）

**优势**: 包体积最小、配置灵活

### 环境要求

- JDK 17+
- Maven 3.6+
- Node.js 16+ (仅用于前端开发)

### 1. 编译项目

```bash
# 克隆项目
git clone <your-repo-url>
cd LanDeployer

# 编译后端
cd landeployer-server
mvn clean package -DskipTests

# 编译前端
cd ../landeployer-ui
npm install
npm run build
```

编译后会在 `landeployer-server/target/` 目录生成 `landeployer.jar`

### 2. 运行应用

```bash
# 简单运行
java -jar landeployer-server/target/landeployer.jar

# 或使用一键脚本
bash build.sh  # 构建
java -jar landeployer-server/target/landeployer.jar
```

**后台运行**:
```bash
# 创建目录
mkdir -p /opt/landeployer/{data,logs,storage}
cp landeployer-server/target/landeployer.jar /opt/landeployer/

# 后台运行
cd /opt/landeployer
nohup java -jar landeployer.jar > logs/app.log 2>&1 &

# 查看日志
tail -f logs/app.log
```

应用启动后访问: `http://localhost:8080`

默认账号: `admin / admin123`

---

## 🎯 启动模式对比

| 特性 | Docker | 独立包 | 自动JRE | 传统方式 |
|------|--------|--------|---------|---------|
| 需要安装Java | ❌ | ❌ | ❌ | ✅ |
| 需要安装Docker | ✅ | ❌ | ❌ | ❌ |
| 包体积 | 约100MB | 约120MB | 约50MB | 约30MB |
| 首次需要网络 | ❌ | ❌ | ✅ | ❌ |
| 环境隔离 | ✅ | ❌ | ❌ | ❌ |
| 跨平台 | ✅ | ✅ | ✅ | ✅ |
| 易用性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| 推荐场景 | 生产环境 | 演示/测试 | 开发环境 | 已有Java |

> 📚 **详细部署指南**: 查看 [DEPLOYMENT.md](DEPLOYMENT.md) 了解更多部署选项和最佳实践

---

### 3. 使用流程

#### (1) 添加服务器

进入「服务器管理」页面，添加目标服务器：
- 输入服务器名称、IP、端口
- 配置SSH认证（支持密码和私钥）
- 设置远程部署路径（默认 `/opt/offline`）
- 点击「测试」验证连接

#### (2) 准备离线资源

将以下文件上传到服务器的对应目录：

```
/opt/offline/
├── images/          # Docker镜像tar包
│   ├── openresty.tar
│   ├── redis.tar
│   ├── mysql.tar
│   ├── prometheus.tar
│   ├── grafana.tar
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
docker pull prom/node-exporter:v1.6.0
docker pull prom/mysqld-exporter:v0.15.0
docker pull oliver006/redis_exporter:v1.55.0

# 导出为tar包
docker save -o openresty.tar openresty/openresty:1.25.3.1-alpine
docker save -o redis.tar redis:7.2
docker save -o mysql.tar mysql:8.0.35
docker save -o prometheus.tar prom/prometheus:v2.45.0
docker save -o grafana.tar grafana/grafana:10.0.0
docker save -o node-exporter.tar prom/node-exporter:v1.6.0
docker save -o mysqld-exporter.tar prom/mysqld-exporter:v0.15.0
docker save -o redis-exporter.tar oliver006/redis_exporter:v1.55.0

# 拷贝到内网服务器
scp *.tar root@<内网IP>:/opt/offline/images/
```

**拷贝配置文件:**

```bash
# 将项目中的scripts目录内容拷贝到服务器
cd LanDeployer/scripts
scp -r compose config root@<内网IP>:/opt/offline/
scp load.sh root@<内网IP>:/opt/offline/
```

#### (3) 创建部署任务

进入「部署任务」页面：
1. **选择服务器** - 从列表中选择在线的服务器
2. **选择角色** - 勾选需要部署的服务（如OpenResty、Redis等）
3. **检查资源** - 系统自动检查是否缺失镜像包或配置文件
4. **开始部署** - 输入任务名称，点击「开始部署」

#### (4) 查看任务进度

部署任务会在后台异步执行，可以在「任务历史」页面查看：
- 实时进度
- 执行日志
- 成功/失败状态

## 📂 目录结构

```
LanDeployer/
├── landeployer-server/          # 后端项目
│   ├── src/main/java/
│   │   └── com/landeployer/
│   │       ├── controller/      # 控制器
│   │       ├── service/         # 服务层
│   │       ├── repository/      # 数据访问层
│   │       ├── entity/          # 实体类
│   │       ├── dto/             # 数据传输对象
│   │       └── config/          # 配置类
│   └── src/main/resources/
│       ├── application.yml      # 配置文件
│       └── static/              # 前端打包文件
├── landeployer-ui/              # 前端项目
│   ├── src/
│   │   ├── views/               # 页面组件
│   │   ├── api/                 # API接口
│   │   ├── router/              # 路由配置
│   │   └── App.vue
│   ├── package.json
│   └── vite.config.js
├── scripts/                      # 脚本和配置
│   ├── compose/                 # Docker Compose文件
│   ├── config/                  # 服务配置文件
│   ├── load.sh                  # 镜像加载脚本
│   └── install.sh               # 安装脚本
├── pom.xml                      # Maven父项目
└── README.md                    # 项目文档
```

## 🔧 开发指南

### 后端开发

```bash
cd landeployer-server
mvn spring-boot:run
```

访问: `http://localhost:8080`

### 前端开发

```bash
cd landeployer-ui
npm install
npm run dev
```

访问: `http://localhost:3000`

前端开发服务器会自动代理API请求到后端(8080端口)。

### 数据库

项目使用SQLite作为数据库，数据文件位于 `data/landeployer.db`

首次启动会自动创建表结构和初始化默认角色数据。

## 🚀 生产部署

> 💡 生产环境推荐使用 **Docker部署** 或 **独立包部署**

### 方案A: Docker部署（推荐）

```bash
# 1. 构建并导出镜像
bash build-docker.sh
# 生成 landeployer-docker.tar

# 2. 拷贝到生产服务器
scp landeployer-docker.tar root@prod-server:/opt/landeployer/
scp docker-compose-landeployer.yml root@prod-server:/opt/landeployer/

# 3. 在生产服务器上加载并启动
ssh root@prod-server
cd /opt/landeployer
docker load -i landeployer-docker.tar
docker-compose -f docker-compose-landeployer.yml up -d

# 4. 查看状态
docker ps
docker logs -f landeployer
```

### 方案B: 独立包部署

```bash
# 1. 构建独立包
bash build-standalone.sh
# 生成 dist/landeployer-standalone-v1.0.0-linux.tar.gz

# 2. 拷贝到生产服务器
scp dist/landeployer-standalone-v1.0.0-linux.tar.gz root@prod-server:/opt/

# 3. 解压并启动
ssh root@prod-server
cd /opt
tar xzf landeployer-standalone-v1.0.0-linux.tar.gz
cd landeployer-standalone-v1.0.0
./start.sh
```

### 方案C: 传统方式（需要JDK）

```bash
# 1. 打包
cd landeployer-ui
npm run build

cd ../landeployer-server
mvn clean package -DskipTests

# 2. 部署
mkdir -p /opt/landeployer/{data,logs,storage}
cp target/landeployer.jar /opt/landeployer/

# 3. 运行
cd /opt/landeployer
nohup java -jar landeployer.jar > logs/app.log 2>&1 &
```

### 使用systemd管理

创建服务文件 `/etc/systemd/system/landeployer.service`:

```ini
[Unit]
Description=LanDeployer Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/landeployer
ExecStart=/usr/bin/java -jar /opt/landeployer/landeployer.jar
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务:

```bash
systemctl daemon-reload
systemctl start landeployer
systemctl enable landeployer
systemctl status landeployer
```

## 📝 配置说明

### application.yml

主要配置项：

```yaml
server:
  port: 8080                      # 服务端口

app:
  remote-path: /opt/offline       # 默认远程路径
  local-storage: ./storage        # 本地存储路径
  script-path: ./scripts          # 脚本目录
  ssh-timeout: 30000              # SSH超时时间（毫秒）
```

### 角色配置

系统预置了以下部署角色：

| 角色 | 镜像 | 端口 | 说明 |
|-----|------|------|------|
| openresty | openresty:1.25.3.1-alpine | 80,443,9145 | 高性能Web平台 |
| redis | redis:7.2 | 6379,9121 | 缓存数据库 |
| mysql | mysql:8.0.35 | 3306,9104 | 关系型数据库 |
| prometheus | prometheus:v2.45.0 | 9090 | 监控系统 |
| grafana | grafana:10.0.0 | 3000 | 可视化面板 |
| springboot | eclipse-temurin:17 / tomcat:9 | 8080,8081 | Java应用 |
| node-exporter | node-exporter:v1.6.0 | 9100 | 节点监控 |

## ❓ 常见问题

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

### Q: 部署任务一直运行不完成？

A: 可能原因：
1. Docker镜像包太大，加载时间长
2. 服务启动较慢
3. 查看任务日志获取详细信息

### Q: 如何添加自定义服务？

A: 需要：
1. 在数据库中添加新的角色记录
2. 准备对应的docker-compose文件
3. 将镜像tar包上传到服务器

## 📄 许可证

本项目采用 MIT 许可证。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📧 联系方式

如有问题，请通过Issue反馈。

---

**注意**: 本工具专为内网离线环境设计，请确保在安全可控的环境中使用。


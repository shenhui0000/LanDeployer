# LanDeployer 部署方案

本文档提供了多种部署方案，包括**无需JDK**的部署方式。

## 🎯 部署方案对比

| 方案 | 优点 | 缺点 | 推荐场景 |
|------|------|------|----------|
| **方案1: Docker部署** | ✅ 无需安装Java<br>✅ 环境隔离<br>✅ 易于管理 | ❌ 需要Docker | 生产环境、服务器部署 |
| **方案2: 独立包（含JRE）** | ✅ 无需安装Java<br>✅ 开箱即用<br>✅ 跨平台 | ❌ 包体积较大(~200MB) | 桌面环境、演示 |
| **方案3: 自动下载JRE** | ✅ 首次自动配置<br>✅ 后续无感知 | ❌ 首次需要网络 | 开发测试环境 |
| **方案4: 传统部署** | ✅ 包体积小<br>✅ 灵活配置 | ❌ 需要预装Java 17+ | 已有Java环境 |

---

## 📦 方案1: Docker部署（推荐）

### 优势
- ✅ **无需安装Java** - Docker镜像已包含JRE
- ✅ 环境一致性 - 避免"我这能运行"问题
- ✅ 易于管理 - 一条命令启动/停止
- ✅ 支持离线部署

### 步骤

#### 1. 构建Docker镜像

```bash
# 构建项目和Docker镜像
bash build-docker.sh

# 会生成：
# - Docker镜像: landeployer:latest
# - 离线tar包: landeployer-docker.tar
```

#### 2. 运行（在线环境）

```bash
# 使用Docker Compose（推荐）
docker-compose -f docker-compose-landeployer.yml up -d

# 或使用Docker命令
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  -v $(pwd)/storage:/app/storage \
  --name landeployer \
  landeployer:latest
```

#### 3. 离线部署

```bash
# 在有网络的机器上
bash build-docker.sh
# 生成 landeployer-docker.tar

# 拷贝到离线机器
scp landeployer-docker.tar user@target-host:/tmp/
scp docker-compose-landeployer.yml user@target-host:/opt/landeployer/

# 在离线机器上
cd /opt/landeployer
docker load -i /tmp/landeployer-docker.tar
docker-compose -f docker-compose-landeployer.yml up -d
```

#### 4. 管理命令

```bash
# 查看日志
docker logs -f landeployer

# 停止
docker-compose -f docker-compose-landeployer.yml stop

# 启动
docker-compose -f docker-compose-landeployer.yml start

# 重启
docker-compose -f docker-compose-landeployer.yml restart

# 删除
docker-compose -f docker-compose-landeployer.yml down
```

---

## 📦 方案2: 独立部署包（内含JRE）

### 优势
- ✅ **无需安装Java** - 使用jlink创建精简JRE
- ✅ 开箱即用 - 解压即可运行
- ✅ 跨平台 - 支持Linux/Mac/Windows

### 步骤

#### 1. 构建独立包

```bash
# 需要本地安装JDK 17+ (仅构建时需要)
bash build-standalone.sh

# 会生成：
# dist/landeployer-standalone-v1.0.0-linux.tar.gz
# dist/landeployer-standalone-v1.0.0-windows.zip
```

#### 2. 部署到目标机器

**Linux/Mac:**
```bash
# 解压
tar xzf landeployer-standalone-v1.0.0-linux.tar.gz
cd landeployer-standalone-v1.0.0

# 运行
./start.sh
```

**Windows:**
```cmd
# 解压 landeployer-standalone-v1.0.0-windows.zip
# 双击 start.bat 即可运行
```

#### 3. 目录结构

```
landeployer-standalone-v1.0.0/
├── landeployer.jar      # 应用程序
├── jre/                 # 精简Java运行环境（约50-80MB）
├── start.sh             # Linux/Mac启动脚本
├── start.bat            # Windows启动脚本
├── data/                # 数据目录
├── logs/                # 日志目录
├── storage/             # 存储目录
├── README.md
├── INSTALL.md
└── 快速开始.txt
```

---

## 📦 方案3: 自动下载JRE

### 优势
- ✅ 首次运行自动配置JRE
- ✅ 后续运行无需网络
- ✅ 包体积小

### 步骤

```bash
# 1. 构建项目
bash build.sh

# 2. 运行（首次会提示下载JRE）
bash run-with-bundled-jre.sh

# 首次运行时：
# - 自动检测操作系统和架构
# - 提示是否下载JRE
# - 下载并配置JRE（约50-80MB）
# - 启动应用

# 后续运行：
# - 直接使用已下载的JRE
# - 无需网络连接
```

---

## 📦 方案4: 传统部署（需要JDK）

### 前提条件
- 目标机器已安装Java 17+

### 步骤

```bash
# 1. 构建
bash build.sh

# 2. 拷贝jar包
cp landeployer-server/target/landeployer.jar /opt/landeployer/

# 3. 运行
cd /opt/landeployer
java -jar landeployer.jar

# 或后台运行
nohup java -jar landeployer.jar > logs/app.log 2>&1 &
```

---

## 🔧 性能优化

### JVM参数建议

```bash
# 小型环境（<10台服务器）
java -Xms256m -Xmx512m -jar landeployer.jar

# 中型环境（10-50台服务器）
java -Xms512m -Xmx1024m -jar landeployer.jar

# 大型环境（50+台服务器）
java -Xms1024m -Xmx2048m -jar landeployer.jar

# 启用GC日志
java -Xlog:gc*:file=logs/gc.log -jar landeployer.jar
```

### Docker资源限制

```yaml
# docker-compose-landeployer.yml
services:
  landeployer:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

---

## 🔐 安全加固

### 1. 修改默认密码

首次登录后立即修改密码（功能待实现，当前可通过数据库修改）

### 2. 限制访问IP

```bash
# 使用iptables限制
iptables -A INPUT -p tcp --dport 8080 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j DROP

# 或使用Nginx反向代理
# 配置IP白名单
```

### 3. 启用HTTPS

```bash
# 生成自签名证书（测试用）
keytool -genkeypair -alias landeployer \
  -keyalg RSA -keysize 2048 \
  -storetype PKCS12 -keystore keystore.p12 \
  -validity 3650

# 配置application.yml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: your-password
    key-store-type: PKCS12
```

### 4. SSH密钥安全

- 使用密钥认证代替密码
- 定期轮换密钥
- 限制SSH用户权限

---

## 📊 监控和日志

### 查看日志

```bash
# 应用日志
tail -f logs/landeployer.log

# Docker日志
docker logs -f landeployer

# 实时监控
docker stats landeployer
```

### 日志轮转

```bash
# 创建logrotate配置
sudo nano /etc/logrotate.d/landeployer

# 内容：
/opt/landeployer/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
```

---

## 🆘 故障排查

### 问题1: 端口被占用

```bash
# 查看8080端口占用
netstat -tlnp | grep 8080
# 或
lsof -i:8080

# 修改端口
java -jar landeployer.jar --server.port=8081
```

### 问题2: 内存不足

```bash
# 检查内存使用
free -h

# 增加JVM堆内存
java -Xmx2048m -jar landeployer.jar
```

### 问题3: 数据库损坏

```bash
# 备份数据库
cp data/landeployer.db data/landeployer.db.backup

# 检查数据库
sqlite3 data/landeployer.db "PRAGMA integrity_check;"

# 如损坏，从备份恢复
cp data/landeployer.db.backup data/landeployer.db
```

---

## 🔄 升级指南

### Docker方式升级

```bash
# 1. 停止旧版本
docker-compose -f docker-compose-landeployer.yml down

# 2. 备份数据
cp -r data data.backup

# 3. 加载新镜像
docker load -i landeployer-docker-new.tar

# 4. 启动新版本
docker-compose -f docker-compose-landeployer.yml up -d
```

### 独立包方式升级

```bash
# 1. 停止应用（Ctrl+C）

# 2. 备份数据和配置
cp -r data data.backup

# 3. 替换jar包
cp landeployer-new.jar landeployer.jar

# 4. 重启
./start.sh
```

---

## 📚 相关文档

- [README.md](README.md) - 项目概述和快速开始
- [INSTALL.md](INSTALL.md) - 详细安装指南
- [DEPLOYMENT.md](DEPLOYMENT.md) - 本文档

---

## ❓ 常见问题

**Q: 哪种方案最适合生产环境？**
A: Docker方式，环境隔离、易于管理、方便升级。

**Q: 我的环境没有Docker，应该选哪种？**
A: 使用"独立部署包（内含JRE）"方案，无需安装任何依赖。

**Q: 包含JRE的独立包有多大？**
A: 使用jlink精简后约80-120MB（含应用），未精简约200-250MB。

**Q: 是否支持ARM架构（如树莓派）？**
A: 支持，自动下载JRE方案会自动检测架构。

**Q: 可以部署在Windows Server上吗？**
A: 可以，支持所有方案，推荐使用Docker Desktop或独立包。

---

**祝您使用愉快！**

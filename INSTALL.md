# LanDeployer 安装指南

本文档详细说明如何在内网环境中部署和使用 LanDeployer。

## 📋 目录

- [环境准备](#环境准备)
- [准备离线资源](#准备离线资源)
- [安装步骤](#安装步骤)
- [配置说明](#配置说明)
- [使用流程](#使用流程)

## 环境准备

### 控制机（运行LanDeployer的机器）

- 操作系统：Linux / MacOS / Windows
- JDK 17+
- 网络：能够SSH连接到目标服务器

### 目标服务器（部署服务的机器）

- 操作系统：Linux (推荐 CentOS 7+, Ubuntu 18.04+)
- Docker 20.10+
- Docker Compose 1.29+
- SSH服务已启动
- root权限或sudo权限

## 准备离线资源

### 1. 准备Docker镜像

在有外网的机器上执行：

```bash
# 创建临时目录
mkdir -p /tmp/landeployer-offline/images
cd /tmp/landeployer-offline/images

# 拉取所需镜像
echo "正在拉取Docker镜像..."
docker pull openresty/openresty:1.25.3.1-alpine
docker pull redis:7.2
docker pull mysql:8.0.35
docker pull prom/prometheus:v2.45.0
docker pull grafana/grafana:10.0.0
docker pull prom/node-exporter:v1.6.0
docker pull prom/mysqld-exporter:v0.15.0
docker pull oliver006/redis_exporter:v1.55.0
docker pull eclipse-temurin:17-jdk-alpine
docker pull tomcat:9-jdk17

# 导出镜像为tar包
echo "正在导出镜像..."
docker save -o openresty.tar openresty/openresty:1.25.3.1-alpine
docker save -o redis.tar redis:7.2
docker save -o mysql.tar mysql:8.0.35
docker save -o prometheus.tar prom/prometheus:v2.45.0
docker save -o grafana.tar grafana/grafana:10.0.0
docker save -o node-exporter.tar prom/node-exporter:v1.6.0
docker save -o mysqld-exporter.tar prom/mysqld-exporter:v0.15.0
docker save -o redis-exporter.tar oliver006/redis_exporter:v1.55.0
docker save -o springboot.tar eclipse-temurin:17-jdk-alpine tomcat:9-jdk17

echo "镜像导出完成！"
ls -lh *.tar
```

### 2. 准备配置文件和脚本

从项目源码复制：

```bash
cd /tmp/landeployer-offline
cp -r <项目路径>/LanDeployer/scripts/* .

# 目录结构应该如下：
# /tmp/landeployer-offline/
# ├── images/
# │   ├── openresty.tar
# │   ├── redis.tar
# │   └── ...
# ├── compose/
# │   ├── openresty.yml
# │   ├── redis.yml
# │   └── ...
# ├── config/
# │   ├── openresty/
# │   ├── prometheus/
# │   └── grafana/
# ├── load.sh
# └── install.sh
```

### 3. 打包离线资源

```bash
cd /tmp
tar czf landeployer-offline.tar.gz landeployer-offline/

# 可以通过U盘或其他方式将此压缩包传输到内网
```

## 安装步骤

### 步骤1: 安装LanDeployer控制台

#### 方式A: 使用已编译的jar包

```bash
# 创建目录
mkdir -p /opt/landeployer
cd /opt/landeployer

# 拷贝jar包（需要先编译或从发布版本获取）
cp landeployer.jar /opt/landeployer/

# 创建必要的目录
mkdir -p data logs storage

# 启动应用
java -jar landeployer.jar
```

#### 方式B: 从源码编译

```bash
# 克隆或拷贝项目源码到内网
cd LanDeployer

# 编译前端
cd landeployer-ui
npm install
npm run build

# 编译后端
cd ../landeployer-server
mvn clean package -DskipTests

# 拷贝到目标目录
mkdir -p /opt/landeployer
cp target/landeployer.jar /opt/landeployer/
cd /opt/landeployer
mkdir -p data logs storage

# 启动
java -jar landeployer.jar
```

### 步骤2: 配置systemd服务（推荐）

创建服务文件：

```bash
sudo nano /etc/systemd/system/landeployer.service
```

内容如下：

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
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start landeployer
sudo systemctl enable landeployer
sudo systemctl status landeployer
```

查看日志：

```bash
sudo journalctl -u landeployer -f
```

### 步骤3: 访问Web界面

打开浏览器访问：`http://<服务器IP>:8080`

默认账号密码：`admin / admin123`

### 步骤4: 准备目标服务器

在**每台目标服务器**上执行：

```bash
# 1. 解压离线资源包
cd /opt
tar xzf /path/to/landeployer-offline.tar.gz
mv landeployer-offline offline

# 2. 运行安装脚本
cd /opt/offline
chmod +x install.sh load.sh
bash install.sh

# 3. 给予脚本执行权限
chmod +x load.sh

# 目录结构：
# /opt/offline/
# ├── images/        - Docker镜像tar包
# ├── compose/       - Docker Compose文件
# ├── config/        - 配置文件
# ├── app/           - 应用程序目录
# ├── logs/          - 日志目录
# └── load.sh        - 镜像加载脚本
```

## 配置说明

### LanDeployer配置

配置文件位于 `/opt/landeployer/application.yml` (如果需要自定义)

```yaml
server:
  port: 8080

app:
  remote-path: /opt/offline        # 目标服务器的部署目录
  local-storage: ./storage         # 本地文件存储
  ssh-timeout: 30000               # SSH连接超时（毫秒）
```

### 目标服务器目录说明

```
/opt/offline/
├── images/          # 存放Docker镜像tar包
│   ├── openresty.tar
│   ├── redis.tar
│   └── mysql.tar
├── compose/         # 存放docker-compose文件
│   ├── openresty.yml
│   ├── redis.yml
│   └── mysql.yml
├── config/          # 存放配置文件
│   ├── openresty/
│   │   └── conf.d/
│   │       └── prometheus.conf
│   ├── prometheus/
│   │   └── prometheus.yml
│   └── grafana/
│       └── provisioning/
├── app/             # 存放应用程序（如SpringBoot的jar/war）
└── load.sh          # 镜像加载脚本
```

## 使用流程

### 1. 添加服务器

1. 登录LanDeployer Web界面
2. 点击「服务器管理」
3. 点击「添加服务器」
4. 填写信息：
   - 名称：自定义名称
   - IP地址：目标服务器IP
   - 端口：SSH端口（默认22）
   - 用户名：SSH用户名（建议root）
   - 认证方式：选择密码或私钥
   - 部署路径：`/opt/offline`
5. 点击「测试」验证连接
6. 点击「确定」保存

### 2. 查看资源仓库

1. 点击「资源仓库」
2. 查看系统预置的部署角色
3. 确认每个角色需要的镜像包名称

### 3. 创建部署任务

1. 点击「部署任务」
2. **步骤1：选择服务器**
   - 从列表中选择一台在线的服务器
   - 点击「下一步」
3. **步骤2：选择角色**
   - 勾选需要部署的服务（如OpenResty、Redis、MySQL）
   - 点击「下一步」
4. **步骤3：检查资源**
   - 系统自动检查目标服务器上是否有所需的镜像包
   - 如有缺失，提示用户上传
   - 点击「下一步」
5. **步骤4：开始部署**
   - 输入任务名称
   - 点击「开始部署」

### 4. 查看任务进度

1. 点击「任务历史」
2. 查看任务列表和状态
3. 点击「查看详情」查看执行日志
4. 如果任务正在运行，日志会自动刷新

### 5. 验证部署结果

部署成功后，可以通过以下方式验证：

```bash
# 在目标服务器上查看运行的容器
docker ps

# 查看特定服务的日志
docker logs openresty
docker logs redis
docker logs mysql

# 测试服务端口
netstat -tlnp | grep 80    # OpenResty
netstat -tlnp | grep 6379  # Redis
netstat -tlnp | grep 3306  # MySQL
```

访问服务：
- OpenResty: `http://<服务器IP>`
- Grafana: `http://<服务器IP>:3000` (admin/admin)
- Prometheus: `http://<服务器IP>:9090`

## 高级用法

### 部署SpringBoot应用

1. 将jar或war包上传到目标服务器：
   ```bash
   scp app.jar root@<服务器IP>:/opt/offline/app/
   ```

2. 在LanDeployer中选择「springboot」角色进行部署

3. 访问应用：
   - JAR方式：`http://<服务器IP>:8080`
   - WAR方式：`http://<服务器IP>:8081`

### 自定义配置文件

修改目标服务器上的配置文件：

```bash
# OpenResty配置
vi /opt/offline/config/openresty/conf.d/default.conf

# Prometheus配置
vi /opt/offline/config/prometheus/prometheus.yml

# 重新部署服务使配置生效
docker-compose -f /opt/offline/compose/openresty.yml restart
```

### 批量部署到多台服务器

1. 在LanDeployer中添加多台服务器
2. 为每台服务器创建独立的部署任务
3. 任务会并发执行，互不影响

## 故障排查

### 问题1: SSH连接失败

**现象**: 测试连接时提示连接失败

**解决**:
```bash
# 检查目标服务器SSH服务
systemctl status sshd

# 检查防火墙
firewall-cmd --list-ports
# 或
iptables -L -n

# 手动测试SSH连接
ssh root@<服务器IP>
```

### 问题2: Docker镜像加载失败

**现象**: 部署任务日志显示镜像加载错误

**解决**:
```bash
# 检查tar包是否存在
ls -lh /opt/offline/images/

# 手动加载镜像测试
cd /opt/offline/images
docker load -i openresty.tar

# 检查Docker服务
systemctl status docker
docker info
```

### 问题3: 容器启动失败

**现象**: docker-compose up 失败

**解决**:
```bash
# 查看详细错误
docker-compose -f /opt/offline/compose/openresty.yml up

# 查看容器日志
docker logs <容器名>

# 检查端口占用
netstat -tlnp | grep <端口>

# 检查磁盘空间
df -h
```

### 问题4: 任务一直处于运行状态

**现象**: 任务进度卡住不动

**解决**:
1. 在任务详情中查看日志输出
2. 登录目标服务器手动检查
3. 可能是网络延迟或Docker加载时间过长
4. 等待或手动在服务器上执行命令

## 卸载

### 卸载LanDeployer控制台

```bash
# 停止服务
systemctl stop landeployer
systemctl disable landeployer

# 删除服务文件
rm /etc/systemd/system/landeployer.service

# 删除程序文件
rm -rf /opt/landeployer

# 重载systemd
systemctl daemon-reload
```

### 清理目标服务器

```bash
# 停止所有容器
cd /opt/offline/compose
for yml in *.yml; do
    docker-compose -f $yml down
done

# 删除镜像（可选）
docker images | grep -E "openresty|redis|mysql|prometheus|grafana" | awk '{print $3}' | xargs docker rmi -f

# 删除离线文件
rm -rf /opt/offline
```

## 后续维护

### 备份

重要数据：
- LanDeployer数据库：`/opt/landeployer/data/landeployer.db`
- 配置文件：`/opt/offline/config/`
- 应用数据：Docker volumes

```bash
# 备份LanDeployer数据
tar czf landeployer-backup-$(date +%Y%m%d).tar.gz /opt/landeployer/data

# 备份Docker volumes
docker run --rm -v mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql-data-$(date +%Y%m%d).tar.gz /data
```

### 更新镜像

1. 在外网机器拉取新版本镜像
2. 导出为tar包
3. 拷贝到内网服务器
4. 在LanDeployer中重新部署

## 技术支持

如遇到问题，请：
1. 查看日志：`/opt/landeployer/logs/landeployer.log`
2. 查看任务详情中的执行日志
3. 提交Issue到项目仓库

---

安装完成后，您可以开始使用LanDeployer进行服务部署了！


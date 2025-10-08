# Docker 镜像文件说明

本目录包含了 LanDeployer 项目所需的所有 Docker 镜像（AMD64 架构）。

## 镜像列表

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

## 使用方法

### 1. 下载镜像文件

从 GitHub Release 或其他渠道下载所需的 `.tar` 文件。

### 2. 上传到目标服务器

```bash
# 使用 scp 上传到服务器
scp *.tar user@server:/opt/offline/images/

# 或使用 rsync
rsync -avz --progress *.tar user@server:/opt/offline/images/
```

### 3. 导入镜像

在目标服务器上执行：

```bash
# 进入镜像目录
cd /opt/offline/images/

# 导入单个镜像
docker load -i openresty.tar

# 或批量导入所有镜像
for file in *.tar; do
    echo "正在导入: $file"
    docker load -i "$file"
done
```

### 4. 验证镜像

```bash
# 查看已导入的镜像
docker images

# 应该能看到以下镜像：
# openresty/openresty:1.25.3.1-alpine
# redis:7.2
# oliver006/redis_exporter:v1.55.0
# mysql:8.0.35
# prom/mysqld-exporter:v0.15.0
# prom/prometheus:v2.45.0
# prom/node-exporter:v1.6.0
# grafana/grafana:10.0.0
# eclipse-temurin:8-jdk-alpine
# tomcat:9-jdk8
```

### 5. 启动服务

```bash
# 使用 docker-compose 启动服务
cd /opt/offline
docker-compose -f compose/redis.yml up -d
docker-compose -f compose/mysql.yml up -d
# ... 启动其他服务
```

## 注意事项

1. **架构兼容性**: 这些镜像是 `linux/amd64` 架构，仅适用于 x86_64 服务器
2. **存储空间**: 确保目标服务器有至少 5GB 的可用磁盘空间
3. **网络隔离**: 这些镜像可以在完全离线的环境中使用
4. **版本锁定**: 所有镜像版本已锁定，避免兼容性问题

## 重新生成镜像

如需重新导出镜像，在项目根目录执行：

```bash
# 导出所有镜像
./export-images.sh

# （可选）打包镜像
./package-images.sh
```

## 许可证

这些镜像均为开源软件，遵循各自项目的许可证：
- OpenResty: BSD License
- Redis: BSD License
- MySQL: GPL v2
- Prometheus/Grafana/Exporters: Apache 2.0
- Eclipse Temurin: GPLv2 with Classpath Exception
- Tomcat: Apache 2.0


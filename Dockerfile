FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="LanDeployer"
LABEL description="LanDeployer - 离线内网部署工具"

# 设置工作目录
WORKDIR /app

# 安装必要的工具
RUN apk add --no-cache \
    openssh-client \
    bash \
    curl

# 创建必要的目录
RUN mkdir -p /app/data /app/logs /app/storage

# 复制jar包
COPY landeployer-server/target/landeployer.jar /app/landeployer.jar

# 暴露端口
EXPOSE 8080

# 设置环境变量
ENV JAVA_OPTS="-Xms512m -Xmx1024m"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/landeployer.jar"]

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

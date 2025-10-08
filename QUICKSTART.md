# LanDeployer 快速开始指南

## 🎯 3分钟快速上手

### 步骤1: 下载并运行（无需安装任何环境）

```bash
# 1. 下载压缩包（根据您的系统选择）
# macOS (Apple Silicon): landeployer-python-darwin-arm64.tar.gz
# macOS (Intel): landeployer-python-darwin-x86_64.tar.gz
# Linux: landeployer-python-linux-x86_64.tar.gz

# 2. 解压
tar xzf landeployer-python-*.tar.gz

# 3. 进入目录
cd landeployer-release

# 4. 运行
./start.sh
```

**就这样！** 打开浏览器访问 `http://localhost:8080`

默认账号: `admin` / `admin123`

---

### 步骤2: 添加服务器

1. 点击左侧菜单「服务器管理」
2. 点击「添加服务器」
3. 填写信息：
   - 名称：测试服务器
   - IP：192.168.1.100
   - 端口：22
   - 用户名：root
   - 认证方式：密码
   - 密码：你的密码
   - 部署路径：/opt/offline
4. 点击「测试」验证连接
5. 点击「确定」保存

---

### 步骤3: 准备目标服务器

在目标服务器上执行：

```bash
# 1. 安装Docker（如未安装）
curl -fsSL https://get.docker.com | sh

# 2. 创建目录
mkdir -p /opt/offline/{images,compose,config}

# 3. 上传离线资源（在有网络的机器上）
# 下载Docker镜像
docker pull openresty/openresty:1.25.3.1-alpine
docker pull redis:7.2
docker pull mysql:8.0.35

# 导出镜像
docker save -o openresty.tar openresty/openresty:1.25.3.1-alpine
docker save -o redis.tar redis:7.2
docker save -o mysql.tar mysql:8.0.35

# 4. 拷贝到目标服务器
scp *.tar root@192.168.1.100:/opt/offline/images/
scp -r LanDeployer/scripts/compose root@192.168.1.100:/opt/offline/
scp -r LanDeployer/scripts/config root@192.168.1.100:/opt/offline/
```

---

### 步骤4: 创建部署任务

1. 点击左侧菜单「部署任务」
2. **选择服务器** - 勾选刚才添加的服务器
3. **选择角色** - 比如勾选 Redis、MySQL
4. **检查资源** - 系统会自动检查文件是否存在
5. **开始部署** - 输入任务名称，点击「开始部署」

---

### 步骤5: 查看部署进度

1. 点击左侧菜单「任务历史」
2. 点击「查看详情」查看实时日志
3. 等待部署完成

---

## ✅ 验证部署

在目标服务器上：

```bash
# 查看运行的容器
docker ps

# 测试Redis
docker exec -it redis redis-cli ping
# 应该返回: PONG

# 测试MySQL
docker exec -it mysql mysql -uroot -proot@123 -e "SELECT 1"
```

---

## 🎉 完成！

现在您可以：
- 访问服务：`http://目标服务器IP:端口`
- 查看Grafana：`http://目标服务器IP:3000`
- 使用部署的服务

---

## 💡 提示

- 支持批量部署多台服务器
- 可以查看历史部署任务
- 支持部署任务失败重试
- 所有操作都有详细日志

---

## ❓ 遇到问题？

查看 [README.md](README.md) 获取详细文档


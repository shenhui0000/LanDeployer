# 上传镜像到 GitHub Release 指南

## 方式一：通过 GitHub 网页界面（推荐）

### 1. 创建 Release

1. 访问项目的 GitHub 页面
2. 点击右侧的 **Releases**
3. 点击 **Draft a new release**
4. 填写信息：
   - **Tag version**: `v1.0.0` (或其他版本号)
   - **Release title**: `LanDeployer v1.0.0 - Docker Images`
   - **Description**: 描述此版本包含的内容

### 2. 上传镜像文件

在 Release 编辑页面底部：

1. 点击 **Attach binaries by dropping them here or selecting them**
2. 选择 `images/` 目录下的所有 `.tar` 文件
3. 等待上传完成（可能需要较长时间，总计约 1.8GB）

### 3. 发布

点击 **Publish release** 完成发布。

## 方式二：使用 GitHub CLI

### 1. 安装 GitHub CLI

```bash
# macOS
brew install gh

# Linux
# 参考: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

### 2. 登录

```bash
gh auth login
```

### 3. 创建 Release 并上传

```bash
# 进入项目目录
cd /Users/redbeab/Documents/project/我的项目/LanDeployer

# 创建 release
gh release create v1.0.0 \
  --title "LanDeployer v1.0.0 - Docker Images" \
  --notes "包含所有必需的 Docker 镜像文件 (AMD64 架构)" \
  images/*.tar
```

## 方式三：使用 Git LFS（适合频繁更新）

### 1. 安装 Git LFS

```bash
# macOS
brew install git-lfs

# 初始化
git lfs install
```

### 2. 跟踪镜像文件

```bash
# 跟踪 .tar 文件
git lfs track "images/*.tar"

# 添加 .gitattributes
git add .gitattributes
```

### 3. 提交并推送

```bash
git add images/*.tar
git commit -m "Add Docker images (AMD64)"
git push origin main
```

**注意**: Git LFS 有存储配额限制，免费账户为 1GB/月带宽。

## 下载使用

用户可以通过以下方式下载：

### 从 Release 下载（推荐）

```bash
# 下载单个文件
wget https://github.com/<用户名>/LanDeployer/releases/download/v1.0.0/openresty.tar

# 下载所有文件
cd /tmp
wget https://github.com/<用户名>/LanDeployer/releases/download/v1.0.0/openresty.tar
wget https://github.com/<用户名>/LanDeployer/releases/download/v1.0.0/redis.tar
wget https://github.com/<用户名>/LanDeployer/releases/download/v1.0.0/mysql.tar
# ... 其他文件
```

### 使用脚本批量下载

创建 `download-images.sh`:

```bash
#!/bin/bash

VERSION="v1.0.0"
REPO="<用户名>/LanDeployer"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"

IMAGES=(
    "openresty.tar"
    "redis.tar"
    "redis-exporter.tar"
    "mysql.tar"
    "mysqld-exporter.tar"
    "prometheus.tar"
    "node-exporter.tar"
    "grafana.tar"
    "temurin-jdk8.tar"
    "tomcat9-jdk8.tar"
)

mkdir -p images
cd images

for image in "${IMAGES[@]}"; do
    echo "下载: $image"
    wget "${BASE_URL}/${image}"
done

echo "下载完成！"
```

## 文件大小限制

GitHub Release 限制：
- 单个文件最大: **2GB**
- 当前所有文件均小于 2GB ✓

如果单个文件超过 2GB，需要：
1. 分割文件: `split -b 1G file.tar file.tar.part`
2. 分别上传各部分
3. 下载后合并: `cat file.tar.part* > file.tar`

## 推荐配置

建议在 `README.md` 中添加下载链接：

```markdown
## 下载镜像

请从 [Releases](https://github.com/<用户名>/LanDeployer/releases) 页面下载所需的 Docker 镜像文件。

### 快速下载

```bash
# 使用 wget 批量下载
bash download-images.sh
```

## 替代方案

如果 GitHub Release 上传/下载速度较慢，可以考虑：

1. **国内镜像站**: 使用 Gitee 同步（最大 1GB/文件）
2. **对象存储**: 阿里云 OSS、腾讯云 COS、七牛云等
3. **网盘分享**: 百度网盘、阿里云盘等
4. **Docker Registry**: 自建或使用公共 Registry

## 更新镜像

当需要更新镜像时：

```bash
# 1. 重新导出镜像
./export-images.sh

# 2. 创建新版本
gh release create v1.1.0 \
  --title "LanDeployer v1.1.0 - Updated Images" \
  --notes "更新镜像版本" \
  images/*.tar
```


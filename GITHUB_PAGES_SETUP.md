# GitHub Pages 设置指南

## 🌐 启用 GitHub Pages

官网首页已创建并提交到仓库。现在需要在 GitHub 上启用 GitHub Pages：

### 步骤 1: 进入仓库设置

1. 打开浏览器，访问你的仓库：
   ```
   https://github.com/shenhui0000/LanDeployer
   ```

2. 点击页面上方的 **Settings** (设置) 标签

### 步骤 2: 配置 GitHub Pages

1. 在左侧菜单中找到 **Pages** 选项（在 Code and automation 分组下）

2. 在 **Source** (源) 部分：
   - 选择 **Deploy from a branch** (从分支部署)

3. 在 **Branch** (分支) 部分：
   - Branch: 选择 `main`
   - Folder: 选择 `/docs`
   - 点击 **Save** (保存)

### 步骤 3: 等待部署

GitHub 会自动开始构建和部署你的网站，这通常需要 1-2 分钟。

完成后，页面顶部会显示：
```
Your site is live at https://shenhui0000.github.io/LanDeployer/
```

## 🎉 访问你的官网

部署成功后，可以通过以下地址访问：

```
https://shenhui0000.github.io/LanDeployer/
```

## 📝 更新官网

如果需要修改官网内容：

1. 编辑 `docs/index.html` 文件
2. 提交并推送到 GitHub：
   ```bash
   git add docs/index.html
   git commit -m "更新官网内容"
   git push origin main
   ```
3. GitHub Pages 会自动重新部署（1-2 分钟后生效）

## 🔧 自定义域名（可选）

如果你有自己的域名，可以配置自定义域名：

1. 在 Pages 设置页面，找到 **Custom domain** 部分
2. 输入你的域名（例如：`landeployer.example.com`）
3. 在你的 DNS 提供商处添加 CNAME 记录：
   ```
   landeployer CNAME shenhui0000.github.io
   ```

## ✨ 官网特性

你的项目官网包含以下内容：

- 🎨 **现代化设计**: 紫色渐变主题，简约美观
- 📱 **响应式布局**: 完美支持手机、平板、桌面端
- 🚀 **核心功能展示**: 6 大核心功能介绍
- 🐳 **支持服务列表**: 展示所有可部署的服务
- 📦 **下载中心**: 直接链接到 GitHub Release
- 💻 **快速开始**: 包含完整的安装和使用说明
- 🔗 **便捷导航**: 平滑滚动，良好的用户体验

## 🛠️ 技术实现

- **纯静态页面**: 单个 HTML 文件，无需构建
- **自适应设计**: CSS Grid + Flexbox 布局
- **性能优化**: 无外部依赖，加载速度快
- **SEO 友好**: 适当的 meta 标签和语义化 HTML

## 📊 访问统计（可选）

如果想添加访问统计，可以集成 Google Analytics：

1. 在 Google Analytics 创建账号
2. 在 `docs/index.html` 的 `<head>` 中添加跟踪代码
3. 提交并推送更新

## 🎯 下一步

- ✅ 官网已创建并提交
- ⏳ 在 GitHub 启用 Pages（需手动操作）
- ⏳ 等待部署完成
- ⏳ 访问并分享你的官网链接

---

**提示**: GitHub Pages 是免费的，每个仓库都可以拥有一个项目网站！


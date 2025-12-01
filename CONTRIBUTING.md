# 贡献指南

感谢您对本项目的关注！我们欢迎所有形式的贡献，包括但不限于：

- 报告问题（Bug Reports）
- 功能建议（Feature Requests）
- 提交代码（Pull Requests）
- 改进文档（Documentation Improvements）

## 贡献流程

### 1. Fork 仓库

首先，Fork 本仓库到您的账户。

### 2. 创建分支

从 `main` 分支创建一个新的功能分支：

```bash
git checkout -b feat/your-feature-name
# 或
git checkout -b fix/your-bug-fix
```

分支命名规范：
- `feat/`: 新功能
- `fix/`: Bug 修复
- `docs/`: 文档更新
- `refactor/`: 代码重构
- `test/`: 测试相关

### 3. 进行修改

#### Dockerfile 编写规范

1. **指令大小写**: 所有 Dockerfile 指令必须使用大写（FROM, RUN, COPY 等）
2. **注释**: 为每个主要步骤添加注释，说明其目的
3. **层优化**: 合理合并 RUN 指令以减少镜像层数
4. **安全性**: 
   - 避免在镜像中硬编码敏感信息
   - 使用非 root 用户运行应用（ModelArts 镜像使用 ma-user）
   - 及时更新基础镜像和依赖包版本
5. **可维护性**: 
   - 保持代码清晰易读
   - 使用有意义的变量名
   - 遵循现有代码风格

#### 代码检查

在提交前，请确保：

1. **Hadolint 检查**: 运行 hadolint 检查 Dockerfile 语法
   ```bash
   # 安装 hadolint (如果未安装)
   # macOS: brew install hadolint
   # Linux: 从 https://github.com/hadolint/hadolint/releases 下载
   
   # 检查所有 Dockerfile
   find . -name "*.Dockerfile" -exec hadolint {} \;
   ```

2. **语法验证**: 使用 docker build 的 `--dry-run` 或实际构建验证语法
   ```bash
   docker build --dry-run -f path/to/Dockerfile .
   ```

3. **文档更新**: 如果添加了新的 Dockerfile，请更新 README.md

### 4. 提交更改

提交信息应清晰描述所做的更改：

```bash
git add .
git commit -m "feat: 添加 CANN 8.4 支持"
```

提交信息格式：
- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式调整（不影响功能）
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建过程或辅助工具的变动

### 5. 推送并创建 Pull Request

```bash
git push origin feat/your-feature-name
```

然后在 GitHub/Gitee 上创建 Pull Request，并填写 PR 描述：

- 说明更改的目的和背景
- 列出主要变更点
- 如有相关 issue，请引用
- 添加测试说明（如适用）

## Dockerfile 最佳实践

### 1. 基础镜像选择

- 优先使用官方维护的基础镜像
- 明确指定版本标签，避免使用 `latest`
- 选择合适的基础镜像大小（Alpine vs Ubuntu）

### 2. 层缓存优化

```dockerfile
# 好的做法：将变化频率低的操作放在前面
RUN apt-get update && apt-get install -y package1 package2

# 不好的做法：频繁变化的操作放在前面
COPY frequently-changing-file.txt /app/
RUN apt-get update && apt-get install -y package1
```

### 3. 减少镜像大小

- 使用 `--no-cache` 安装包
- 及时清理 apt/yum 缓存
- 删除临时文件和构建依赖
- 使用多阶段构建（如适用）

### 4. 安全性

```dockerfile
# 好的做法：使用非 root 用户
USER ma-user
WORKDIR /home/ma-user

# 避免：在镜像中存储密钥
# ENV API_KEY=secret-key  # 不要这样做
```

### 5. 环境变量

- 使用 ENV 设置环境变量
- 为变量提供默认值（如适用）
- 避免硬编码路径和配置

## 代码审查

所有 Pull Request 都需要经过代码审查。审查者会检查：

1. 代码质量和规范性
2. Dockerfile 最佳实践
3. 文档完整性
4. 测试覆盖（如适用）

请耐心等待审查，并根据反馈进行修改。

## 问题报告

如果您发现了问题，请创建 Issue 并包含：

1. **问题描述**: 清晰描述问题
2. **复现步骤**: 如何复现该问题
3. **预期行为**: 应该发生什么
4. **实际行为**: 实际发生了什么
5. **环境信息**: 
   - Docker 版本
   - 操作系统
   - 相关 Dockerfile 路径
6. **日志信息**: 如有错误日志，请附上

## 功能建议

如果您有功能建议，请创建 Issue 并说明：

1. **功能描述**: 详细描述建议的功能
2. **使用场景**: 在什么情况下会用到这个功能
3. **可能的实现**: 如果有实现思路，欢迎分享

## 许可证

通过贡献代码，您同意您的贡献将在与项目相同的许可证（MIT License）下发布。

## 联系方式

如有任何问题，请通过以下方式联系：

- 创建 Issue
- 提交 Pull Request 并在描述中说明

感谢您的贡献！


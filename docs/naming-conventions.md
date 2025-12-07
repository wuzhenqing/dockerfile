# 命名规范

本文档说明项目中 Dockerfile 的命名规则和组织方式。

## 目录结构原则

项目采用**按项目分类的目录结构**：

- 每个项目有独立的目录
- 同一项目的不同版本放在同一目录下
- 通过文件名区分不同的平台版本

## Dockerfile 命名格式

### 基本格式

```
{版本标识}-{平台标识}.Dockerfile
```

### 平台标识

#### `base` - 基础版本

- **用户**：root
- **工作目录**：`/root`
- **pip 配置**：全局配置（`pip config set`）
- **适用场景**：
  - 本地开发环境
  - 测试环境
  - 需要完整 root 权限的场景
  - 自由度高的开发调试

#### `modelarts` - ModelArts 版本

- **用户**：ma-user (UID 1000, GID 100)
- **工作目录**：`/home/ma-user`
- **pip 配置**：用户级配置（`pip config --user set`）
- **适用场景**：
  - 华为云 ModelArts 平台
  - 需要特定用户权限的云环境
  - 多租户环境

### 命名示例

#### 通用项目

| 文件名 | 说明 |
|--------|------|
| `dev-base.Dockerfile` | 开发环境的基础版本 |
| `dev-modelarts.Dockerfile` | 开发环境的 ModelArts 版本 |
| `prod-base.Dockerfile` | 生产环境的基础版本 |
| `prod-modelarts.Dockerfile` | 生产环境的 ModelArts 版本 |

#### 版本化项目（如 CANN）

| 文件名 | 说明 |
|--------|------|
| `8.3.RC1-base.Dockerfile` | CANN 8.3 RC1 的基础版本 |
| `8.3.RC1.alpha003-modelarts.Dockerfile` | CANN 8.3 RC1 alpha003 的 ModelArts 版本 |
| `8.2.RC1.alpha002-modelarts.Dockerfile` | CANN 8.2 RC1 alpha002 的 ModelArts 版本 |

#### 框架项目（包含多个依赖版本）

| 文件名 | 说明 |
|--------|------|
| `2.7-cann8.2-modelarts.Dockerfile` | MindSpore 2.7 + CANN 8.2 的 ModelArts 版本 |
| `3.0-cann8.3-base.Dockerfile` | 假设的 MindSpore 3.0 + CANN 8.3 基础版本 |

## 环境标识说明

常用的环境标识：

- **`dev`** - 开发环境，包含完整的开发工具和调试工具
- **`prod`** - 生产环境，精简的运行时环境
- **`test`** - 测试环境，包含测试工具和框架

## 目录组织示例

### 单项目结构

```
project-name/
├── dev-base.Dockerfile
├── dev-modelarts.Dockerfile
├── prod-base.Dockerfile
└── prod-modelarts.Dockerfile
```

### 多版本项目结构

```
project-name/
├── 1.0-base.Dockerfile
├── 1.0-modelarts.Dockerfile
├── 2.0-base.Dockerfile
├── 2.0-modelarts.Dockerfile
└── scripts/
    └── helper.sh
```

## 配套文件命名

### 脚本文件

- `entrypoint.sh` - 容器启动脚本
- `setup.sh` - 环境配置脚本
- `build.sh` - 构建辅助脚本

### 配置文件

- `config.yaml` - 配置文件
- `requirements.txt` - Python 依赖
- `packages.list` - 系统包列表

## 添加新项目

当添加新项目时，请遵循以下步骤：

1. **创建项目目录**

```bash
mkdir project-name/
```

2. **创建基础版本 Dockerfile**

```bash
touch project-name/dev-base.Dockerfile
```

3. **创建 ModelArts 版本 Dockerfile**

```bash
touch project-name/dev-modelarts.Dockerfile
```

4. **确保两个版本同步**

除了用户相关配置外，两个版本应保持相同的：
- 系统包
- Python 包
- 工具链
- 环境变量（除用户路径外）

5. **更新主 README**

在项目列表中添加新项目的说明

## 版本管理建议

### Git 标签

为重要版本创建 Git 标签：

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### Docker 镜像标签

构建镜像时使用清晰的标签：

```bash
# 语义化版本
docker tag image:latest image:v1.0.0

# 包含构建信息
docker tag image:latest image:v1.0.0-cann8.3-py3.11-ubuntu22.04

# 便捷标签
docker tag image:v1.0.0 image:v1.0
docker tag image:v1.0.0 image:v1
docker tag image:v1.0.0 image:latest
```

## 最佳实践

1. **保持一致性** - 所有项目使用相同的命名规则
2. **语义清晰** - 文件名应该自解释，不需要额外说明
3. **避免冗余** - 不要在文件名中重复项目名称（因为已经在目录中）
4. **版本号清晰** - 使用官方版本号，不要自创版本标识
5. **及时更新文档** - 添加新项目后立即更新文档

## 反模式（避免）

❌ 不好的命名：

```
Dockerfile                          # 不明确
Dockerfile.bak                      # 备份文件不应该存在
asnumpy-dev-base.Dockerfile         # 项目名重复（已在目录中）
cann_8.3_rc1_base.Dockerfile        # 使用下划线，不一致
8.3-modelarts-final.Dockerfile      # "final" 含义不明确
```

✅ 好的命名：

```
dev-base.Dockerfile
dev-modelarts.Dockerfile
8.3.RC1-base.Dockerfile
8.3.RC1.alpha003-modelarts.Dockerfile
2.7-cann8.2-modelarts.Dockerfile
```


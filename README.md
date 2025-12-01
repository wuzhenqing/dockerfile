# CANN Dockerfile 仓库

## 项目介绍

本仓库用于存储可以在 ModelArts 平台使用的 Docker 镜像的 Dockerfile，所有镜像均已安装 CANN Toolkit 与 Kernels。

这些 Dockerfile 提供了基于华为昇腾 NPU 的开发环境，适用于：
- ModelArts 平台上的 AI 模型训练和推理
- 本地开发环境搭建
- CI/CD 流程中的容器化构建

## 目录结构

```
.
├── base/                                                   # 基础镜像 Dockerfile
│   └── cann/                                               # CANN 基础镜像
│       ├── CANN8.3.RC1.Dockerfile
│       └── entrypoint.sh                                   # 入口脚本
├── modelarts/                                              # ModelArts 专用镜像
│   ├── cann/                                               # CANN 相关镜像
│   │   ├── CANN8.1.RC1.beta1.Dockerfile
│   │   ├── CANN8.2.RC1.alpha002.Dockerfile
│   │   ├── CANN8.2.RC1.alpha003.Dockerfile
│   │   └── CANN8.3.RC1.alpha003.Dockerfile
│   ├── mindspore/                                          # MindSpore 框架镜像
│   │   └── MindSpore2.7-CANN8.2.RC1.alpha003.Dockerfile
│   ├── pyasc/                                              # PyASC 开发镜像
│   │   └── pyasc-dev.Dockerfile
│   └── asnumpy/                                            # asnumpy 开发镜像
│       └── asnumpy-dev.Dockerfile
├── README.md                                               # 本文件
├── README.en.md                                            # 英文说明
├── LICENSE                                                 # 许可证文件
└── .gitignore                                              # Git 忽略配置
```

## Dockerfile 说明

### base/cann/

#### CANN8.3.RC1.Dockerfile
- **基础镜像**: `ascendai/cann:8.3.rc1-910b-ubuntu22.04-py3.11`
- **用途**: 提供完整的 CANN 开发环境，包含 LLVM/Clang 工具链、Python 开发工具和 SSH 服务
- **主要组件**:
  - LLVM 19.1.7 (从源码编译)
  - Python 开发工具包（numpy, scipy, pytest 等）
  - SSH 服务器配置
  - 时区和本地化设置

### modelarts/cann/

#### CANN8.1.RC1.beta1.Dockerfile
- **基础镜像**: `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.1.rc1-910b-ubuntu22.04-py3.11`
- **用途**: ModelArts 平台使用的 CANN 8.1 版本镜像
- **特点**: 配置了 ma-user 用户（UID 1000, GID 100）用于 ModelArts 兼容性

#### CANN8.2.RC1.alpha002.Dockerfile
- **基础镜像**: `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.2.rc1.alpha002-910b-ubuntu22.04-py3.10`
- **用途**: ModelArts 平台使用的 CANN 8.2 alpha002 版本镜像
- **特点**: 包含 Miniconda 和基础 Python 包

#### CANN8.2.RC1.alpha003.Dockerfile
- **基础镜像**: `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.2.rc1.alpha003-910b-ubuntu22.04-py3.11`
- **用途**: ModelArts 平台使用的 CANN 8.2 alpha003 版本镜像
- **特点**: 包含 PyTorch 和 torch-npu 支持

#### CANN8.3.RC1.alpha003.Dockerfile
- **基础镜像**: `ascendai/cann:8.3.rc1.alpha003-910b-ubuntu22.04-py3.11`
- **用途**: ModelArts 平台使用的 CANN 8.3 alpha003 版本镜像
- **特点**: 包含 PyTorch 和 torch-npu 支持

### modelarts/mindspore/

#### MindSpore2.7-CANN8.2.RC1.alpha003.Dockerfile
- **基础镜像**: `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.2.rc1.alpha003-910b-ubuntu22.04-py3.11`
- **用途**: 提供 MindSpore 2.7.0 框架与 CANN 8.2 的集成环境
- **主要组件**:
  - MindSpore 2.7.0
  - Miniconda 环境
  - CANN Toolkit 集成

### modelarts/pyasc/

#### pyasc-dev.Dockerfile
- **基础镜像**: `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha003-910b-ubuntu22.04-py3.11`
- **用途**: PyASC 开发环境，包含从源码编译的 LLVM
- **主要组件**:
  - LLVM 19.1.7 (从源码编译，包含 MLIR, Clang, LLD)
  - Python 构建工具（cmake, ninja, pybind11 等）
  - 开发测试工具（pytest, pytest-xdist 等）

### modelarts/asnumpy/

#### asnumpy-dev.Dockerfile
- **基础镜像**: `swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha002-910b-ubuntu22.04-py3.11`
- **用途**: asnumpy 开发环境
- **主要组件**:
  - 基础开发工具
  - numpy 和 pytest

## 构建和使用

### 构建镜像

#### 基础镜像构建

```bash
# 构建 base/cann 镜像
cd base/cann
docker build -f CANN8.3.RC1.Dockerfile -t cann-base:8.3.rc1 .

# 注意：构建前需要准备依赖文件
# - clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz (放在 /root/ 目录下)
# - entrypoint.sh (在同一目录下)
```

#### ModelArts 镜像构建

```bash
# 构建 CANN 镜像
cd modelarts/cann
docker build -f CANN8.3.RC1.alpha003.Dockerfile -t cann-modelarts:8.3.alpha003 .

# 构建 MindSpore 镜像
cd ../mindspore
docker build -f MindSpore2.7-CANN8.2.RC1.alpha003.Dockerfile -t mindspore-cann:2.7-8.2 .

# 构建 PyASC 开发镜像
cd ../pyasc
docker build -f pyasc-dev.Dockerfile -t pyasc-dev:latest .
# 注意：需要准备 llvm-project-19.1.7.src.tar.xz 文件

# 构建 asnumpy 开发镜像
cd ../asnumpy
docker build -f asnumpy-dev.Dockerfile -t asnumpy-dev:latest .
```

### 在 ModelArts 中使用

1. 将构建好的镜像推送到华为云 SWR
2. 在 ModelArts 镜像管理中注册镜像
3. 在创建 notebook 的时候可以选择自定义镜像

## 版本信息

### CANN 版本
- CANN 8.3 RC1
- CANN 8.2 RC1 (alpha002, alpha003)
- CANN 8.1 RC1 (beta1)

### Python 版本
- Python 3.11 (大部分镜像)
- Python 3.10 (CANN8.2.RC1.alpha002)

### 其他组件版本
- MindSpore: 2.7.0
- LLVM: 19.1.7
- PyTorch: 最新稳定版
- torch-npu: 2.7.1rc1

## 依赖文件说明

部分 Dockerfile 需要额外的依赖文件，构建前请确保准备：

1. **base/cann/CANN8.3.RC1.Dockerfile**
   - `clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz` - LLVM 预编译包
   - `entrypoint.sh` - 入口脚本

2. **modelarts/pyasc/pyasc-dev.Dockerfile**
   - `llvm-project-19.1.7.src.tar.xz` - LLVM 源码包

## 注意事项

1. **架构要求**: 所有镜像均为 ARM64 (aarch64) 架构，适用于昇腾 910B 处理器
2. **用户权限**: ModelArts 镜像使用 `ma-user` 用户（UID 1000），确保文件权限正确
3. **网络配置**: 镜像中已配置华为云镜像源，加速包下载
4. **SSH 配置**: 基础镜像包含 SSH 服务器，可通过环境变量 `HOST_SSH_PUB_KEY` 配置公钥
5. **存储空间**: 构建镜像需要较大磁盘空间（建议至少 50GB）

## 贡献指南

欢迎贡献新的 Dockerfile 或改进现有配置。请参考 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细的贡献流程。

## 许可证

本项目采用 [MIT License](LICENSE) 许可证。

## 相关链接

- [华为昇腾 AI 处理器](https://www.hiascend.com/)
- [CANN 文档](https://www.hiascend.com/document)
- [ModelArts 平台](https://www.huaweicloud.com/product/modelarts.html)
- [MindSpore 官网](https://www.mindspore.cn/)

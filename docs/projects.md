# 项目说明

本文档详细介绍各个项目的特性、用途和配置。

## asnumpy

### 简介

**NumPy-like API for Ascend NPU**

asnumpy 提供类似 NumPy 的 API，使得昇腾 NPU 编程更加简单直观。开发者可以使用熟悉的 NumPy 语法在昇腾硬件上执行计算。

### 镜像信息

- **基础镜像**：`swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha002-910b-ubuntu22.04-py3.11`
- **Python 版本**：3.11
- **Ubuntu 版本**：22.04

### 主要依赖

- numpy
- pytest（测试框架）

### 预装工具

完整的开发工具链，包括：
- C/C++ 编译工具（clang, cmake, ninja）
- 代码搜索工具（ripgrep, fd-find）
- 系统监控工具（btop, ncdu, neofetch）
- 调试工具（gdb, strace, lsof）
- 终端管理（tmux）

### 构建示例

```bash
# 基础版本（本地开发）
docker build -f asnumpy/dev-base.Dockerfile -t asnumpy:dev-base .

# ModelArts 版本（云平台）
docker build -f asnumpy/dev-modelarts.Dockerfile -t asnumpy:dev-modelarts .
```

### 适用场景

- NumPy 代码迁移到昇腾 NPU
- 科学计算和数据分析
- 算法原型开发

---

## cann-base

### 简介

**CANN (Compute Architecture for Neural Networks) 基础镜像**

CANN 是华为昇腾异构计算架构的基础运行时环境。本项目维护多个 CANN 版本的镜像，支持不同的开发和部署需求。

### 支持的版本

| 版本 | Python | 特性 | Dockerfile |
|------|--------|------|------------|
| **8.3 RC1** | 3.11 | 最新稳定版，带 LLVM 19.1.7 工具链 | `8.3.RC1-base.Dockerfile` |
| 8.3 RC1 alpha003 | 3.11 | 包含 PyTorch 2.x 和 torch-npu 支持 | `8.3.RC1.alpha003-modelarts.Dockerfile` |
| 8.2 RC1 alpha003 | 3.11 | 稳定版，包含完整科学计算栈 | `8.2.RC1.alpha003-modelarts.Dockerfile` |
| 8.2 RC1 alpha002 | 3.10 | 包含 Miniconda 环境 | `8.2.RC1.alpha002-modelarts.Dockerfile` |
| 8.1 RC1 beta1 | 3.11 | 旧版本，包含 XMake 构建系统 | `8.1.RC1.beta1-modelarts.Dockerfile` |

### 8.3 RC1（推荐）

**最完整的开发环境**

#### 特性

- LLVM/Clang 19.1.7 工具链（预编译版本）
- 完整的系统监控和调试工具
- SSH 服务配置
- 自定义 entrypoint 脚本

#### 主要 Python 包

```
attrs==24.2.0, build, decorator==5.1.1, filecheck, lit
numpy==1.26.4, psutil==6.0.0, pybind11==2.13.1
pytest==8.3.2, pytest-xdist==3.6.1, pyyaml
scipy==1.13.1, setuptools>=71, typing_extensions, wheel
```

#### 环境变量

```bash
LLVM_INSTALL_PREFIX=/opt/llvm
PATH=$LLVM_INSTALL_PREFIX/bin:$PATH
LD_LIBRARY_PATH=$LLVM_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH
CC=$LLVM_INSTALL_PREFIX/bin/clang
CXX=$LLVM_INSTALL_PREFIX/bin/clang++
PYASC_DUMP_PATH=/root/.cache/pyasc
PYASC_SETUP_CLANG_LLD=1
```

#### 构建要求

需要准备 LLVM 预编译包：
```bash
# 放置在项目根目录
/root/clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz
```

### 8.3 RC1 alpha003

**PyTorch 开发环境**

包含 PyTorch 2.x 和 torch-npu==2.7.1rc1，适合 PyTorch 模型开发和训练。

### 其他版本

旧版本主要用于兼容性测试和特定项目维护。

### entrypoint.sh

8.3 RC1 base 版本包含启动脚本，自动处理：
- 加载 Ascend 环境变量
- SSH 密钥配置
- 容器内 SSH 服务启动

---

## mindspore

### 简介

**MindSpore - 华为全场景深度学习框架**

MindSpore 是华为开源的深度学习框架，支持端边云全场景部署。提供自动微分、图算融合等特性，在昇腾硬件上有优异的性能。

### 镜像信息

- **基础镜像**：CANN 8.2 RC1 alpha003
- **MindSpore 版本**：2.7.0
- **Python 环境**：Miniconda3 (Python 3.11)

### 主要特性

- ✅ 预装 Miniconda 环境
- ✅ 自动加载 Ascend 环境变量
- ✅ 完整的科学计算栈（NumPy, SciPy）
- ✅ Ascend 工具包集成（te, hccl）

### 主要依赖

```
sympy, numpy==1.26.0, scipy
attrs, cython, decorator, cffi, pyyaml
pathlib2, psutil, protobuf==3.20
requests, absl-py
mindspore==2.7.0
```

### 构建示例

```bash
docker build -f mindspore/2.7-cann8.2-modelarts.Dockerfile -t mindspore:2.7 .
```

### 特殊配置

- Ascend 目录权限：`chmod -R 777 /usr/local/Ascend`
- 自动加载环境：`source /usr/local/Ascend/ascend-toolkit/latest/bin/setenv.bash`
- 包含开发库：libeigen3-dev, libboost-all-dev

### 适用场景

- MindSpore 模型开发和训练
- 深度学习算法研究
- 端边云协同推理

---

## pyasc

### 简介

**Python for Ascend - 昇腾 Python 编程框架**

pyasc 为昇腾 NPU 提供 Python 编程接口，支持从源码构建 LLVM，提供深度定制的开发环境。

### 镜像信息

- **基础镜像**：CANN 8.3 RC1 alpha003
- **LLVM 版本**：19.1.7（从源码构建）
- **Python 版本**：3.11

### 主要特性

- 🔧 从源码构建 LLVM/MLIR/Clang/LLD
- 🎯 针对 AArch64 架构优化
- 📦 包含完整的编译工具链
- ⚡ 启用 ccache 加速编译

### LLVM 构建配置

```cmake
-DCMAKE_BUILD_TYPE=Release
-DLLVM_ENABLE_ASSERTIONS=ON
-DLLVM_ENABLE_PROJECTS="mlir;clang;lld"
-DLLVM_TARGETS_TO_BUILD="AArch64"
-DCMAKE_INSTALL_PREFIX=/opt/llvm
-DCMAKE_C_COMPILER=clang
-DCMAKE_CXX_COMPILER=clang++
-DLLVM_CCACHE_BUILD=ON
-DLLVM_USE_LINKER=lld
-DLLVM_INSTALL_UTILS=ON
-DLLVM_BUILD_TESTS=ON
```

### 构建要求

需要准备 LLVM 源码包：
```bash
# 放置在 /tmp 目录
llvm-project-19.1.7.src.tar.xz
```

### Python 依赖

**构建工具**：
```
cmake>=3.20,<4.0
ninja>=1.11.1
pybind11==2.13.1
setuptools>=71
setuptools-scm>=8,<9
wheel
```

**运行时依赖**：
```
attrs==24.2.0, numpy==1.26.4, scipy==1.13.1
decorator==5.1.1, psutil==6.0.0
pytest==8.3.2, pytest-xdist==3.6.1
pyyaml, typing_extensions
```

### 环境变量

```bash
LLVM_INSTALL_PREFIX=/opt/llvm
```

### 构建示例

```bash
# 准备源码包
cp llvm-project-19.1.7.src.tar.xz /tmp/

# 构建镜像（耗时较长，建议使用多核编译）
docker build -f pyasc/dev-modelarts.Dockerfile -t pyasc:dev .
```

### 构建时间

⏱️ LLVM 从源码构建大约需要 **2-4 小时**（取决于 CPU 核心数）

### 适用场景

- LLVM/MLIR 开发
- 编译器后端开发
- 深度定制的 NPU 编程
- 编译优化研究

---

## 版本选择指南

### 场景 1：快速开发和测试

**推荐**：asnumpy 项目

- 轻量级，构建快速
- 包含常用开发工具
- 适合算法原型开发

### 场景 2：深度学习模型训练

**推荐**：mindspore 或 cann-base 8.3 RC1 alpha003

- MindSpore：华为框架，昇腾优化
- CANN with PyTorch：使用 PyTorch API

### 场景 3：编译器和工具链开发

**推荐**：pyasc 或 cann-base 8.3 RC1

- 完整的 LLVM 工具链
- 支持深度定制
- 包含调试和分析工具

### 场景 4：生产部署

**推荐**：根据使用的框架选择

- 本地部署：使用 `*-base.Dockerfile`
- ModelArts 部署：使用 `*-modelarts.Dockerfile`

## 常见问题

### Q: 如何选择 CANN 版本？

A: 一般推荐使用最新的稳定版（8.3 RC1），除非有特定的兼容性需求。

### Q: base 和 modelarts 版本有什么区别？

A: 主要是用户权限和配置路径的差异，功能和工具链完全相同。详见[使用指南](usage-guide.md#版本差异)。

### Q: 可以在 base 镜像中添加 ma-user 吗？

A: 可以，但不推荐。建议直接使用对应的 modelarts 版本。

### Q: 镜像太大怎么办？

A: 可以考虑：
1. 使用多阶段构建
2. 移除不必要的工具
3. 清理临时文件
4. 使用 `.dockerignore`


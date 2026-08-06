# Dockerfile 项目

> 基于华为昇腾 CANN 的容器镜像构建项目，支持多种深度学习和 AI 框架

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

## 简介

本项目维护了一系列基于华为昇腾 CANN (Compute Architecture for Neural Networks) 的 Docker 镜像构建文件，为不同的使用场景提供优化的开发和运行环境。

## 目录结构

```
/root/dockerfile/
├── asnumpy/              # asnumpy 项目（NumPy API for Ascend）
├── cann-base/            # CANN 基础镜像（多版本）
├── llvm/                 # LLVM 源码编译开发基础镜像
├── mindspore/            # MindSpore 深度学习框架
├── pyasc/                # PyASC 项目（Python for Ascend）
├── docs/                 # 详细文档
└── README.md             # 本文档
```

## 支持的项目

| 项目 | 说明 | 文档 |
|------|------|------|
| **asnumpy** | NumPy-like API for Ascend NPU | [详情](docs/projects.md#asnumpy) |
| **cann-base** | CANN 基础运行时环境（多版本） | [详情](docs/projects.md#cann-base) |
| **llvm** | LLVM、Clang 和 MLIR 源码编译开发环境 | [详情](llvm/README.md) |
| **mindspore** | 华为全场景深度学习框架 | [详情](docs/projects.md#mindspore) |
| **pyasc** | 昇腾 Python 编程框架 | [详情](docs/projects.md#pyasc) |

## 快速开始

### 构建镜像

```bash
# asnumpy 开发环境（本地开发）
docker build -f asnumpy/dev-base.Dockerfile -t asnumpy:dev-base .

# asnumpy 开发环境（ModelArts 云平台）
docker build -f asnumpy/dev-modelarts.Dockerfile -t asnumpy:dev-modelarts .

# CANN 8.3 基础镜像
docker build -f cann-base/8.3.RC1-base.Dockerfile -t cann:8.3-base .

# LLVM 19.1.7 Ubuntu 22.04 开发基础镜像
docker build -f llvm/Dockerfile.ubuntu22.04 -t llvm:19.1.7-ubuntu22.04 llvm

# MindSpore 2.7 环境
docker build -f mindspore/2.7-cann8.2-modelarts.Dockerfile -t mindspore:2.7 .
```

### 运行容器

```bash
# 本地开发环境
docker run -it --rm \
  --device=/dev/davinci0 \
  --device=/dev/davinci_manager \
  --device=/dev/devmm_svm \
  --device=/dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  asnumpy:dev-base \
  /bin/bash

# ModelArts 环境
docker run -it --rm \
  --device=/dev/davinci0 \
  -e HOST_SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  asnumpy:dev-modelarts \
  /bin/bash
```

## 版本说明

每个项目提供两种版本的镜像：

- **`*-base.Dockerfile`** - 基础版本（root 用户），适用于本地开发和测试
- **`*-modelarts.Dockerfile`** - ModelArts 版本（ma-user），适用于华为云 ModelArts 平台

详细说明请参考：[版本差异文档](docs/usage-guide.md#版本差异)

## 文档

- 📖 [命名规范](docs/naming-conventions.md) - Dockerfile 命名规则和组织方式
- 🚀 [使用指南](docs/usage-guide.md) - 详细的构建和使用说明
- 📦 [项目说明](docs/projects.md) - 各项目的详细介绍
- 💡 [最佳实践](docs/best-practices.md) - 镜像构建和使用的最佳实践
- 🤝 [贡献指南](docs/contributing.md) - 如何为项目做贡献

## 特性

- 🚀 **双版本支持** - 同时提供本地开发和云平台版本
- 🛠️ **完整工具链** - 预装编译、调试、监控等开发工具
- 📦 **多版本管理** - 支持不同版本的 CANN 和框架
- 🔧 **优化构建** - 精简安装、缓存清理、镜像源优化

## 主要工具

所有开发环境镜像均包含：

- **编译工具**：clang, cmake, ninja, build-essential
- **调试工具**：gdb, strace, lsof
- **监控工具**：btop, ncdu, neofetch
- **搜索工具**：ripgrep, fd-find, jq
- **终端管理**：tmux
- **网络工具**：curl, wget, dnsutils, openssh-server

完整列表请参考：[工具清单](docs/usage-guide.md#预装工具)

## 系统要求

- Docker 或 Podman（推荐 20.10+）
- Linux 操作系统（推荐 Ubuntu 22.04）
- 昇腾硬件（用于运行时）

## 许可证

本项目采用 Apache 2.0 许可证。详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！请查看 [贡献指南](docs/contributing.md) 了解详情。

---

**注意事项**：

- 构建镜像需要良好的网络环境，建议使用国内镜像源
- 部分镜像构建依赖网络下载上游源码或安装包，请确保构建机能访问所需源
- 运行容器需要昇腾驱动支持，请确保主机已正确安装驱动

**相关资源**：

- [CANN 官方文档](https://www.hiascend.com/document)
- [MindSpore 官方文档](https://www.mindspore.cn/docs)

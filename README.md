```
   ██████╗ █████╗ ███╗   ██╗███╗   ██╗
  ██╔════╝██╔══██╗████╗  ██║████╗  ██║
  ██║     ███████║██╔██╗ ██║██╔██╗ ██║
  ██║     ██╔══██║██║╚██╗██║██║╚██╗██║
  ╚██████╗██║  ██║██║ ╚████║██║ ╚████║
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝
  ██████╗  ██████╗  ██████╗██╗  ██╗███████╗██████╗ 
  ██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
  ██║  ██║██║   ██║██║     █████╔╝ █████╗  ██████╔╝
  ██║  ██║██║   ██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
  ██████╔╝╚██████╔╝╚██████╗██║  ██╗███████╗██║  ██║
  ╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
```

<p align="center">
  <strong>🚀 华为昇腾 NPU 开发环境 Dockerfile 集合</strong>
</p>

<p align="center">
  <a href="https://gitee.com/wuzhenqing/dockerfile/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
  </a>
  <a href="https://gitee.com/wuzhenqing/dockerfile">
    <img src="https://img.shields.io/badge/gitee-仓库-red.svg" alt="Gitee">
  </a>
  <a href="https://gitee.com/wuzhenqing/dockerfile/stargazers">
    <img src="https://gitee.com/wuzhenqing/dockerfile/badge/star.svg" alt="Gitee Stars">
  </a>
  <a href="https://gitee.com/wuzhenqing/dockerfile/members">
    <img src="https://gitee.com/wuzhenqing/dockerfile/badge/fork.svg" alt="Gitee Forks">
  </a>
</p>

<p align="center">
  为 ModelArts 平台和本地开发环境提供开箱即用的 CANN 容器镜像
</p>

---

## ✨ 特性亮点

<table>
  <tr>
    <td align="center">🎯<br><b>开箱即用</b><br><sub>预装 CANN Toolkit & Kernels</sub></td>
    <td align="center">🔧<br><b>多版本支持</b><br><sub>CANN 8.1 / 8.2 / 8.3</sub></td>
    <td align="center">🤖<br><b>框架集成</b><br><sub>PyTorch / MindSpore</sub></td>
    <td align="center">☁️<br><b>云端兼容</b><br><sub>ModelArts 平台适配</sub></td>
  </tr>
</table>

---

## 📑 目录

- [🚀 快速开始](#-快速开始)
- [📦 镜像列表](#-镜像列表)
- [📁 项目结构](#-项目结构)
- [🔧 详细使用](#-详细使用)
- [📋 版本兼容性](#-版本兼容性)
- [❓ 常见问题](#-常见问题)
- [🤝 参与贡献](#-参与贡献)
- [📄 许可证](#-许可证)

---

## 🚀 快速开始

### 一键构建（5分钟上手）

```bash
# 克隆仓库
git clone https://gitee.com/wuzhenqing/dockerfile.git
cd dockerfile

# 构建 CANN 8.3 基础镜像
cd modelarts/cann
docker build -f CANN8.3.RC1.alpha003.Dockerfile -t cann:8.3 .

# 运行容器
docker run -it --rm cann:8.3 bash
```

### 在 ModelArts 中使用

```bash
# 1. 构建并推送镜像到华为云 SWR
docker tag cann:8.3 swr.cn-south-1.myhuaweicloud.com/<your-org>/cann:8.3
docker push swr.cn-south-1.myhuaweicloud.com/<your-org>/cann:8.3

# 2. 在 ModelArts 镜像管理中注册
# 3. 创建 Notebook 时选择自定义镜像 ✅
```

---

## 📦 镜像列表

### 🏗️ 基础镜像

| 镜像 | CANN 版本 | Python | 用途 | 特点 |
|:-----|:----------|:-------|:-----|:-----|
| `base/cann/CANN8.3.RC1` | 8.3 RC1 | 3.11 | 通用开发环境 | LLVM 19.1.7 + SSH |

### ☁️ ModelArts 镜像

| 镜像 | CANN 版本 | Python | 框架 | 特点 |
|:-----|:----------|:-------|:-----|:-----|
| `modelarts/cann/CANN8.3.RC1.alpha003` | 8.3 α003 | 3.11 | PyTorch + torch-npu | 🔥 推荐 |
| `modelarts/cann/CANN8.2.RC1.alpha003` | 8.2 α003 | 3.11 | PyTorch + torch-npu | Miniconda |
| `modelarts/cann/CANN8.2.RC1.alpha002` | 8.2 α002 | 3.10 | - | Miniconda |
| `modelarts/cann/CANN8.1.RC1.beta1` | 8.1 β1 | 3.11 | - | 基础开发 |

### 🧠 AI 框架镜像

| 镜像 | 框架版本 | CANN 版本 | Python | 用途 |
|:-----|:---------|:----------|:-------|:-----|
| `modelarts/mindspore/MindSpore2.7-CANN8.2` | MindSpore 2.7.0 | 8.2 α003 | 3.11 | 深度学习训练 |

### 🛠️ 开发工具镜像

| 镜像 | 用途 | 主要工具 |
|:-----|:-----|:---------|
| `modelarts/pyasc/pyasc-dev` | PyASC 编译器开发 | LLVM 19.1.7 (源码编译) + MLIR |
| `modelarts/asnumpy/asnumpy-dev` | asnumpy 开发 | numpy + pytest |

---

## 📁 项目结构

```
dockerfile/
├── 📂 base/                      # 基础镜像
│   └── 📂 cann/
│       ├── 🐳 CANN8.3.RC1.Dockerfile
│       └── 📜 entrypoint.sh
│
├── 📂 modelarts/                 # ModelArts 专用镜像
│   ├── 📂 cann/                  # CANN 环境
│   │   ├── 🐳 CANN8.1.RC1.beta1.Dockerfile
│   │   ├── 🐳 CANN8.2.RC1.alpha002.Dockerfile
│   │   ├── 🐳 CANN8.2.RC1.alpha003.Dockerfile
│   │   └── 🐳 CANN8.3.RC1.alpha003.Dockerfile
│   ├── 📂 mindspore/             # MindSpore 框架
│   │   └── 🐳 MindSpore2.7-CANN8.2.RC1.alpha003.Dockerfile
│   ├── 📂 pyasc/                 # PyASC 开发
│   │   └── 🐳 pyasc-dev.Dockerfile
│   └── 📂 asnumpy/               # asnumpy 开发
│       └── 🐳 asnumpy-dev.Dockerfile
│
├── 📄 README.md
├── 📄 CONTRIBUTING.md
└── 📄 LICENSE
```

---

## 🔧 详细使用

### 构建基础镜像

```bash
cd base/cann

# ⚠️ 构建前需准备依赖文件
# - clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz (放在 /root/ 目录)
# - entrypoint.sh (同目录下)

docker build -f CANN8.3.RC1.Dockerfile -t cann-base:8.3.rc1 .
```

### 构建 ModelArts 镜像

```bash
# CANN 镜像
cd modelarts/cann
docker build -f CANN8.3.RC1.alpha003.Dockerfile -t cann-ma:8.3 .

# MindSpore 镜像
cd ../mindspore
docker build -f MindSpore2.7-CANN8.2.RC1.alpha003.Dockerfile -t mindspore:2.7 .

# PyASC 开发镜像 (需要 llvm-project-19.1.7.src.tar.xz)
cd ../pyasc
docker build -f pyasc-dev.Dockerfile -t pyasc-dev:latest .

# asnumpy 开发镜像
cd ../asnumpy
docker build -f asnumpy-dev.Dockerfile -t asnumpy-dev:latest .
```

### 依赖文件下载

| 文件 | 用途 | 下载地址 |
|:-----|:-----|:---------|
| `clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz` | LLVM 预编译包 | [GitHub Releases](https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.7) |
| `llvm-project-19.1.7.src.tar.xz` | LLVM 源码包 | [GitHub Releases](https://github.com/llvm/llvm-project/releases/tag/llvmorg-19.1.7) |

---

## 📋 版本兼容性

### CANN 与框架版本矩阵

| CANN 版本 | PyTorch | torch-npu | MindSpore | Python |
|:----------|:--------|:----------|:----------|:-------|
| 8.3 RC1 | ✅ 2.x | ✅ 2.7.1rc1 | - | 3.11 |
| 8.2 RC1 α003 | ✅ 2.x | ✅ 2.7.1rc1 | ✅ 2.7.0 | 3.11 |
| 8.2 RC1 α002 | - | - | - | 3.10 |
| 8.1 RC1 β1 | - | - | - | 3.11 |

### 硬件支持

| 处理器 | 架构 | 支持状态 |
|:-------|:-----|:---------|
| 昇腾 910B | ARM64 (aarch64) | ✅ 完全支持 |
| 昇腾 910A | ARM64 (aarch64) | ⚠️ 部分镜像支持 |

---

## ❓ 常见问题

<details>
<summary><b>🔹 镜像构建失败，提示找不到基础镜像？</b></summary>

确保您可以访问华为云 SWR 或 Docker Hub：

```bash
# 测试镜像拉取
docker pull swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha003-910b-ubuntu22.04-py3.11

# 或使用 Docker Hub
docker pull ascendai/cann:8.3.rc1-910b-ubuntu22.04-py3.11
```

</details>

<details>
<summary><b>🔹 在 ModelArts 中无法使用自定义镜像？</b></summary>

1. 确保镜像已推送到华为云 SWR
2. 镜像必须包含 `ma-user` 用户（UID 1000, GID 100）
3. 在 ModelArts 镜像管理中正确注册镜像

</details>

<details>
<summary><b>🔹 构建时下载依赖包很慢？</b></summary>

所有镜像已配置华为云镜像源：
- APT: `mirrors.huaweicloud.com`
- PIP: `repo.huaweicloud.com`

如仍有问题，请检查网络连接。

</details>

<details>
<summary><b>🔹 如何选择合适的镜像？</b></summary>

| 使用场景 | 推荐镜像 |
|:---------|:---------|
| PyTorch 训练/推理 | `CANN8.3.RC1.alpha003` 或 `CANN8.2.RC1.alpha003` |
| MindSpore 开发 | `MindSpore2.7-CANN8.2.RC1.alpha003` |
| 编译器/MLIR 开发 | `pyasc-dev` |
| 轻量级开发测试 | `asnumpy-dev` |

</details>

---

## 🤝 参与贡献

我们欢迎所有形式的贡献！🎉

```bash
# 1. Fork 本仓库
# 2. 创建功能分支
git checkout -b feat/your-feature

# 3. 提交更改
git commit -m "feat: 添加新功能"

# 4. 推送并创建 Pull Request
git push origin feat/your-feature
```

详细指南请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 许可证开源。

---

## 🔗 相关链接

<table>
  <tr>
    <td align="center">
      <a href="https://www.hiascend.com/">
        <img src="https://img.shields.io/badge/昇腾-AI处理器-orange" alt="Ascend">
      </a>
    </td>
    <td align="center">
      <a href="https://www.hiascend.com/document">
        <img src="https://img.shields.io/badge/CANN-文档中心-blue" alt="CANN Docs">
      </a>
    </td>
    <td align="center">
      <a href="https://www.huaweicloud.com/product/modelarts.html">
        <img src="https://img.shields.io/badge/华为云-ModelArts-red" alt="ModelArts">
      </a>
    </td>
    <td align="center">
      <a href="https://www.mindspore.cn/">
        <img src="https://img.shields.io/badge/MindSpore-官网-purple" alt="MindSpore">
      </a>
    </td>
  </tr>
</table>

---

<p align="center">
  <sub>⭐ 如果这个项目对您有帮助，请给一个 Star 支持一下！</sub>
</p>

<p align="center">
  <sub>Made with ❤️ for the Ascend AI community</sub>
</p>

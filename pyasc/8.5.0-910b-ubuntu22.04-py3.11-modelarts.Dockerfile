# ==================== Dockerfile ====================
FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.5.0-910b-ubuntu22.04-py3.11

# 构建参数：用于检测目标平台
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# 打印构建信息（便于调试）
RUN echo "Build platform: $BUILDPLATFORM" && \
    echo "Target platform: $TARGETPLATFORM"

USER root

# ==================== 用户管理 ====================
RUN default_user=$(getent passwd 1000 | awk -F ':' '{print $1}') || echo "uid: 1000 does not exist" && \
    default_group=$(getent group 100 | awk -F ':' '{print $1}') || echo "gid: 100 does not exist" && \
    if [ ! -z ${default_user} ] && [ ${default_user} != "ma-user" ]; then \
        userdel -r ${default_user}; \
    fi && \
    if [ ! -z ${default_group} ] && [ ${default_group} != "ma-group" ]; then \
        groupdel -f ${default_group}; \
    fi && \
    groupadd -g 100 ma-group && useradd -d /home/ma-user -m -u 1000 -g 100 -s /bin/bash ma-user && \
    # Grant the read, write, and execute permissions on the target directory to the user ma-user.
    chmod -R 750 /home/ma-user

# ==================== 基础环境 ====================
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        btop \
        ca-certificates \
        ccache \
        clang \
        clangd \
        cmake \
        curl \
        git \
        lld \
        llvm \
        neofetch \
        net-tools \
        ninja-build \
        openssh-server \
        tzdata \
        unzip \
        vim \
        wget \
        zip \
        zlib1g-dev && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# ==================== Python 依赖 ====================
RUN pip install --upgrade pip && \
    pip install \
        "pybind11==2.13.1" \
        "setuptools>=71" \
        "setuptools-scm>=8,<9" \
        "wheel" && \
    pip install \
        attrs==24.2.0 \
        numpy==1.26.4 \
        scipy==1.13.1 \
        decorator==5.1.1 \
        psutil==6.0.0 \
        pytest==8.3.2 \
        pytest-xdist==3.6.1 \
        pyyaml \
        typing_extensions

# ==================== LLVM 安装（多架构支持）====================
WORKDIR /root

# 根据目标平台选择对应的 LLVM 预编译包
# 注意：aarch64 和 x86_64 的包名格式不同
RUN case "$TARGETPLATFORM" in \
        linux/amd64) \
            echo "Building for x86_64 (amd64)" && \
            LLVM_PKG="LLVM-19.1.7-Linux-X64.tar.xz" && \
            LLVM_DIR="LLVM-19.1.7-Linux-X64" ;; \
        linux/arm64) \
            echo "Building for aarch64 (arm64)" && \
            LLVM_PKG="clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz" && \
            LLVM_DIR="clang+llvm-19.1.7-aarch64-linux-gnu" ;; \
        *) \
            echo "Error: Unsupported platform $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    echo "Downloading LLVM for $TARGETPLATFORM..." && \
    echo "Package: ${LLVM_PKG}" && \
    echo "Extracted dir: ${LLVM_DIR}" && \
    wget -q --show-progress \
        https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/${LLVM_PKG} && \
    tar -xvf ${LLVM_PKG} && \
    mv ${LLVM_DIR} /opt/llvm && \
    rm ${LLVM_PKG} && \
    echo "LLVM installed to /opt/llvm" && \
    /opt/llvm/bin/clang --version && \
    /opt/llvm/bin/ld.lld --version

# ==================== 环境变量（包含链接器设置）====================
ENV LLVM_INSTALL_PREFIX=/opt/llvm \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai \
    PATH=$LLVM_INSTALL_PREFIX/bin:$PATH \
    LD_LIBRARY_PATH=$LLVM_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH \
    # 编译器设置
    CC=$LLVM_INSTALL_PREFIX/bin/clang \
    CXX=$LLVM_INSTALL_PREFIX/bin/clang++ \
    # 链接器设置（使用 LLVM 的 lld）
    LD=$LLVM_INSTALL_PREFIX/bin/ld.lld \
    LDFLAGS="-fuse-ld=lld" \
    # 项目特定设置
    PYASC_DUMP_PATH=/home/ma-user/.cache/pyasc \
    PYASC_SETUP_CLANG_LLD=1

# 验证工具链配置
RUN echo "=== Toolchain Configuration ===" && \
    echo "CC:  $CC" && \
    echo "CXX: $CXX" && \
    echo "LD:  $LD" && \
    echo "LDFLAGS: $LDFLAGS" && \
    echo "" && \
    echo "=== Verify binaries ===" && \
    clang --version && \
    clang++ --version && \
    ld.lld --version

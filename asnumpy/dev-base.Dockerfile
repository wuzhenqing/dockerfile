FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha002-910b-ubuntu22.04-py3.11

USER root

# Configure apt sources and install system packages
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then \
        sed -i "s@http://[^/]*/ubuntu-ports@https://mirrors.huaweicloud.com/ubuntu-ports@g" /etc/apt/sources.list && \
        sed -i "s@http://[^/]*/ubuntu/@https://mirrors.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list; \
    else \
        sed -i "s@http://[^/]*/ubuntu-ports@https://mirrors.huaweicloud.com/ubuntu@g" /etc/apt/sources.list && \
        sed -i "s@http://[^/]*/ubuntu/@https://mirrors.huaweicloud.com/ubuntu/@g" /etc/apt/sources.list; \
    fi && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        # 基础工具
        ca-certificates \
        curl \
        git \
        sudo \
        vim \
        wget \
        # 文件操作工具
        bzip2 \
        rsync \
        tree \
        unzip \
        zip \
        # 文本处理和搜索工具
        fd-find \
        jq \
        ripgrep \
        # 编译和构建工具
        build-essential \
        clang \
        clang-format \
        clangd \
        cmake \
        llvm \
        ninja-build \
        patch \
        # 调试工具
        gdb \
        lsof \
        strace \
        # 系统监控工具
        btop \
        ncdu \
        neofetch \
        # 终端管理
        tmux \
        # 网络工具
        dnsutils \
        iputils-ping \
        net-tools \
        openssh-server \
        traceroute \
        # 文档系统
        man-db && \
    # 更新 locate 数据库
    updatedb && \
    # 清理 apt 缓存以减少镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # 替换 sh 为 bash
    rm /bin/sh && ln -s /bin/bash /bin/sh

WORKDIR /root

# Configure pip and install Python packages for asnumpy development
RUN pip config set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config set global.trusted-host repo.huaweicloud.com && \
    pip install numpy pytest


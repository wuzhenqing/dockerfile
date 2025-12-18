FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha002-910b-ubuntu22.04-py3.11

USER root

# Create ma-user with specific UID/GID for ModelArts compatibility
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

# Configure apt sources and install system packages
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "aarch64" ]; then \
        echo "ERROR: This image only supports aarch64/arm64, got: ${ARCH}" >&2; \
        exit 1; \
    fi && \
    sed -i "s@https\\?://[^/]*/ubuntu-ports/\\?@http://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    sed -i "s@http://repo.huaweicloud.com/ubuntu-ports/@https://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
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

USER ma-user

WORKDIR /home/ma-user

# Configure pip and install Python packages for asnumpy development
RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install numpy pytest


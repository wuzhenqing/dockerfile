FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.5.0-910b-ubuntu22.04-py3.11

USER root

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

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN sed -i "s@https\\?://[^/]*/ubuntu-ports/\\?@http://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
    apt-get update && \
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

RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
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

ENV LLVM_INSTALL_PREFIX=/opt/llvm
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai
ENV LLVM_INSTALL_PREFIX=/opt/llvm
ENV PATH=$LLVM_INSTALL_PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=$LLVM_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH
ENV CC=$LLVM_INSTALL_PREFIX/bin/clang
ENV CXX=$LLVM_INSTALL_PREFIX/bin/clang++
ENV PYASC_DUMP_PATH=/home/ma-user/.cache/pyasc
ENV PYASC_SETUP_CLANG_LLD=1

WORKDIR /root

RUN wget https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz && \
    tar -xvf clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz && \
    mv clang+llvm-19.1.7-aarch64-linux-gnu /opt/llvm && \
    rm clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz

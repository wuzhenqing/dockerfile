FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.5.0-910b-ubuntu22.04-py3.11

USER root

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

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

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        btop \
        build-essential \
        ca-certificates \
        ccache \
        clang \
        clang-format \
        clang-tidy \
        clangd \
        cmake \
        curl \
        file \
        git \
        libfmt-dev \
        libspdlog-dev \
        libzstd-dev \
        lld \
        llvm \
        locales \
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
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo Asia/Shanghai > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Python packages
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir \
        attrs==24.2.0 \
        build==1.4.0 \
        decorator==5.1.1 \
        numpy==1.26.4 \
        psutil==6.0.0 \
        pybind11==2.13.1 \
        pytest==8.3.2 \
        pytest-xdist==3.6.1 \
        pyyaml==6.0.3 \
        scikit-build-core==0.12.0 \
        scipy==1.13.1 \
        setuptools==82 \
        setuptools-scm==8.3.1 \
        wheel==0.46.3 \
        typing_extensions && \
    python3 -m pip install --no-cache-dir torch==2.9.0 --index-url https://download.pytorch.org/whl/cpu && \
    python3 -m pip install --no-cache-dir torch_npu==2.9.0 && \
    python3 -m pip install --no-cache-dir triton-ascend

# LLVM 19.1.7 (build from source with apt clang, host target only)
RUN mkdir -p /opt/llvm && \
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/llvm-project-19.1.7.src.tar.xz && \
    tar -xvf llvm-project-19.1.7.src.tar.xz && \
    cd llvm-project-19.1.7.src && \
    mkdir build && \
    cd build && \
    CC=clang CXX=clang++ cmake ../llvm \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_PROJECTS="mlir;clang;lld" \
        -DLLVM_TARGETS_TO_BUILD=host \
        -DCMAKE_INSTALL_PREFIX=/opt/llvm \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_USE_LINKER=lld \
        -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
        -DLLVM_BUILD_UTILS=ON \
        -DLLVM_INSTALL_UTILS=ON && \
    cmake --build . -- -j"$(nproc)" && \
    cmake --install . && \
    rm -rf /root/llvm-project-19.1.7.src /root/llvm-project-19.1.7.src.tar.xz

# Environment variables
ENV LLVM_INSTALL_PREFIX=/opt/llvm
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_TIME=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    PATH=$PATH:$LLVM_INSTALL_PREFIX/bin \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LLVM_INSTALL_PREFIX/lib \
    CC=$LLVM_INSTALL_PREFIX/bin/clang \
    CXX=$LLVM_INSTALL_PREFIX/bin/clang++ \
    PYASC_DUMP_PATH=/home/ma-user/.cache/pyasc

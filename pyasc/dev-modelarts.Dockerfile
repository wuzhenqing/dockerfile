FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha003-910b-ubuntu22.04-py3.11

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
    apt-get install build-essential vim git llvm clang clangd lld ccache -y && \
    apt-get install zlib1g-dev zip wget curl -y && \
    apt-get install btop neofetch net-tools openssh-server -y && \
    apt clean && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

# Configure pip and install Python build dependencies
RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install "cmake>=3.20,<4.0" "ninja>=1.11.1" "pybind11==2.13.1" "setuptools>=71" "setuptools-scm>=8,<9" "wheel" && \
    pip install attrs==24.2.0 numpy==1.26.4 scipy==1.13.1 decorator==5.1.1 psutil==6.0.0 pytest==8.3.2 pytest-xdist==3.6.1 pyyaml typing_extensions

ENV LLVM_INSTALL_PREFIX=/opt/llvm

# Build and install LLVM from source for pyasc development
COPY llvm-project-19.1.7.src.tar.xz /tmp/

RUN tar -xvf /tmp/llvm-project-19.1.7.src.tar.xz -C /tmp && \
    mv /tmp/llvm-project-19.1.7.src /tmp/llvm-project && \
    mkdir -p /tmp/llvm-project/build && \
    cd /tmp/llvm-project/build && \
    cmake ../llvm \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_ENABLE_PROJECTS="mlir;clang;lld" \
        -DLLVM_TARGETS_TO_BUILD="AArch64" \
        -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_PREFIX} \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_CCACHE_BUILD=ON \
        -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
        -DLLVM_USE_LINKER=lld \
        -DLLVM_INSTALL_UTILS=ON \
        -DLLVM_BUILD_TESTS=ON && \
    ninja && \
    ninja install && \
    rm -rf /tmp/llvm-project /tmp/llvm-project-19.1.7.src.tar.xz


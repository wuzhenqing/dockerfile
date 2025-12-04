FROM ascendai/cann:8.3.rc1-910b-ubuntu22.04-py3.11

USER root

# Configure apt sources
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then \
        sed -i "s@http://[^/]*/ubuntu-ports@https://mirrors.huaweicloud.com/ubuntu-ports@g" /etc/apt/sources.list && \
        sed -i "s@http://[^/]*/ubuntu/@https://mirrors.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list; \
    else \
        sed -i "s@http://[^/]*/ubuntu-ports@https://mirrors.huaweicloud.com/ubuntu@g" /etc/apt/sources.list && \
        sed -i "s@http://[^/]*/ubuntu/@https://mirrors.huaweicloud.com/ubuntu/@g" /etc/apt/sources.list; \
    fi

# Update system packages and install build tools and development utilities
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        # Build Tools and LLVM/Clang Toolchain
        build-essential \
        ccache \
        clang \ 
        clangd \
        cmake \
        gdb \
        lld \ 
        llvm \
        ninja-build \
        pkg-config \
        # Development Tools and System Utilities
        btop \ 
        curl \
        dnsutils \
        git \
        iproute2 \
        locales \
        man-db \
        neofetch \
        net-tools \
        tree \
        tzdata \
        unzip \
        vim \
        wget \
        zip \
        # Libraries
        zlib1g-dev \
        libssl-dev \
        # SSH Server
        openssh-server && \
    apt-get autoclean && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

# Configure timezone and locale
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    locale-gen en_US.UTF-8 zh_CN.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai

# Install LLVM/Clang toolchain
COPY /root/clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz /tmp/

RUN cd /tmp && \
    tar -xvf clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz && \
    mv clang+llvm-19.1.7-aarch64-linux-gnu /opt/llvm && \
    rm clang+llvm-19.1.7-aarch64-linux-gnu.tar.xz

# Configure pip and install Python packages
RUN pip config set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config set global.trusted-host repo.huaweicloud.com && \
    pip install --no-cache-dir \
        attrs==24.2.0 \
        build \
        decorator==5.1.1 \
        filecheck \
        lit \
        numpy==1.26.4 \
        psutil==6.0.0 \
        pybind11==2.13.1 \
        pytest==8.3.2 \
        pytest-xdist==3.6.1 \
        pyyaml \
        scipy==1.13.1 \
        "setuptools>=71" \
        "setuptools-scm>=8,<9" \
        typing_extensions \
        wheel

ENV LLVM_INSTALL_PREFIX=/opt/llvm
ENV PATH=$LLVM_INSTALL_PREFIX/bin:$PATH
ENV LD_LIBRARY_PATH=$LLVM_INSTALL_PREFIX/lib:$LD_LIBRARY_PATH
ENV CC=$LLVM_INSTALL_PREFIX/bin/clang
ENV CXX=$LLVM_INSTALL_PREFIX/bin/clang++
ENV PYASC_DUMP_PATH=/root/.cache/pyasc
ENV PYASC_SETUP_CLANG_LLD=1

# Configure SSH server
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh \
    && echo "PermitRootLogin without-password" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
    && ssh-keygen -A

# Copy and configure entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
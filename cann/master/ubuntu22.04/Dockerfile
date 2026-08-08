FROM ubuntu:22.04

USER root

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        clang \
        clangd \
        cmake \
        curl \
        git \
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncurses5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libzstd-dev \
        lld \
        llvm \
        ninja-build \
        pkg-config \
        wget \
        xz-utils \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://repo.huaweicloud.com/python/3.11.15/Python-3.11.15.tar.xz && \
    tar -xvf Python-3.11.15.tar.xz && cd Python-3.11.15 && \
    mkdir -p /usr/local/python3.11.15/lib && \
    ./configure --enable-shared LDFLAGS="-Wl,-rpath /usr/local/python3.11.15/lib" --prefix=/usr/local/python3.11.15 && \
    make -j"$(nproc)" && \
    make altinstall && \
    ln -sf /usr/local/python3.11.15/bin/python3.11 /usr/local/python3.11.15/bin/python3 && \
    ln -sf /usr/local/python3.11.15/bin/pip3.11 /usr/local/python3.11.15/bin/pip3 && \
    ln -sf /usr/local/python3.11.15/bin/python3 /usr/local/python3.11.15/bin/python && \
    ln -sf /usr/local/python3.11.15/bin/pip3 /usr/local/python3.11.15/bin/pip && \
    cd /root && rm Python-3.11.15.tar.xz && rm -rf Python-3.11.15

ENV PATH=/usr/local/python3.11.15/bin:$PATH

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL

RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    chmod +x Ascend-cann-toolkit.run && \
    chmod +x Ascend-cann-ops.run && \
    ./Ascend-cann-toolkit.run --quiet --install && \
    ./Ascend-cann-ops.run --quiet --install && \
    echo 'source /usr/local/Ascend/cann/set_env.sh' >> /root/.bashrc && \
    rm Ascend-cann-toolkit.run Ascend-cann-ops.run

CMD ["/bin/bash"]

FROM openeuler/openeuler:22.03

USER root

WORKDIR /root

RUN dnf install -y \
        bzip2-devel \
        ca-certificates \
        clang \
        clang-tools-extra \
        cmake \
        curl \
        gcc \
        gcc-c++ \
        git \
        lld \
        llvm \
        libffi-devel \
        liblzma-devel \
        libncurses-devel \
        libzstd-devel \
        make \
        ninja-build \
        openssl-devel \
        pkgconf-pkg-config \
        readline-devel \
        sqlite-devel \
        wget \
        xz \
        zlib-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

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

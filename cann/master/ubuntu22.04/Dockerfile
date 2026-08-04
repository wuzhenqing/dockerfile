FROM ubuntu:22.04

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL
ARG PYTHON_VERSION=3.12.13

USER root

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/local/python${PYTHON_VERSION}/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/python${PYTHON_VERSION}/lib:${LD_LIBRARY_PATH}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        libbz2-dev \
        libev-dev \
        libffi-dev \
        libgdbm-dev \
        liblzma-dev \
        libncurses5-dev \
        libnss3-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        ninja-build \
        wget \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Build Python from source with rpath so libpython resolves without relying solely on LD_LIBRARY_PATH.
RUN curl -fsSL "https://repo.huaweicloud.com/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" \
        -o "/tmp/Python-${PYTHON_VERSION}.tgz" && \
    tar -xf "/tmp/Python-${PYTHON_VERSION}.tgz" -C /tmp && \
    cd "/tmp/Python-${PYTHON_VERSION}" && \
    mkdir -p "/usr/local/python${PYTHON_VERSION}/lib" && \
    ./configure \
        --enable-shared \
        --prefix="/usr/local/python${PYTHON_VERSION}" \
        LDFLAGS="-Wl,-rpath,/usr/local/python${PYTHON_VERSION}/lib" && \
    make -j"$(nproc)" && \
    make altinstall && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/python3.12" "/usr/local/python${PYTHON_VERSION}/bin/python3" && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/pip3.12" "/usr/local/python${PYTHON_VERSION}/bin/pip3" && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/python3" "/usr/local/python${PYTHON_VERSION}/bin/python" && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/pip3" "/usr/local/python${PYTHON_VERSION}/bin/pip" && \
    rm -rf /tmp/*

RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    bash Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    bash Ascend-cann-ops.run --quiet --install --install-for-all && \
    rm -f Ascend-cann-toolkit.run Ascend-cann-ops.run && \
    echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc

CMD ["/bin/bash"]

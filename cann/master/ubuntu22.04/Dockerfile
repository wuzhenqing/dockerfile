ARG PYTHON_VERSION=3.12.13
ARG PYTHON_MAJOR_MINOR=3.12

# Stage 1: Install Python.
FROM ubuntu:22.04 AS python-installer

ARG PYTHON_VERSION
ARG PYTHON_MAJOR_MINOR

USER root
WORKDIR /root

ENV PATH=/usr/local/python${PYTHON_VERSION}/bin:${PATH}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        bash \
        curl \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libncurses5-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libffi-dev \
        libnss3-dev \
        libgdbm-dev \
        liblzma-dev \
        libev-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

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
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/python${PYTHON_MAJOR_MINOR}" "/usr/local/python${PYTHON_VERSION}/bin/python3" && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/pip${PYTHON_MAJOR_MINOR}" "/usr/local/python${PYTHON_VERSION}/bin/pip3" && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/python3" "/usr/local/python${PYTHON_VERSION}/bin/python" && \
    ln -sf "/usr/local/python${PYTHON_VERSION}/bin/pip3" "/usr/local/python${PYTHON_VERSION}/bin/pip" && \
    rm -rf /tmp/*

# Stage 2: Install CANN Toolkit and Ops.
FROM python-installer AS cann-installer

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        git \
        wget \
        gcc \
        g++ \
        make \
        cmake \
        zlib1g \
        openssl \
        unzip \
        pciutils \
        net-tools \
        libblas-dev \
        gfortran \
        patchelf \
        libblas3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        attrs \
        cython \
        numpy \
        decorator \
        sympy \
        cffi \
        pyyaml \
        pathlib2 \
        psutil \
        protobuf==3.20 \
        scipy \
        requests \
        absl-py

RUN wget --quiet "${CANN_TOOLKIT_URL}" -O /root/Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O /root/Ascend-cann-ops.run

RUN chmod +x /root/Ascend-cann-toolkit.run && \
    /root/Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    rm -f /root/Ascend-cann-toolkit.run

RUN chmod +x /root/Ascend-cann-ops.run && \
    /root/Ascend-cann-ops.run --quiet --install --install-for-all && \
    rm -f /root/Ascend-cann-ops.run

# Stage 3: Copy the installed artifacts into the final image.
FROM ubuntu:22.04 AS official-ubuntu

ARG PYTHON_VERSION

USER root
WORKDIR /root

ENV PATH=/usr/local/python${PYTHON_VERSION}/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/python${PYTHON_VERSION}/lib:${LD_LIBRARY_PATH}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        apt-transport-https \
        ca-certificates \
        bash \
        libc6 \
        libsqlite3-dev \
        gcc \
        g++ \
        make \
        cmake \
        git \
        vim \
        wget \
        jq \
        curl \
        build-essential \
        libnuma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

COPY --from=cann-installer /usr/local/python${PYTHON_VERSION} /usr/local/python${PYTHON_VERSION}
COPY --from=cann-installer /usr/local/Ascend /usr/local/Ascend
COPY --from=cann-installer /etc/Ascend /etc/Ascend

RUN echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc

CMD ["/bin/bash"]

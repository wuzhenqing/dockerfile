# Stage 1: Install Python
FROM swr.cn-southwest-2.myhuaweicloud.com/wuzhenqing/ubuntu:22.04 AS python-installer

# Python Environment variables
ENV PATH=/usr/local/python3.11.13/bin:${PATH}

RUN sed -i "s@https\\?://[^/]*/ubuntu-ports/\\?@http://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
    apt-get update && \
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
        libev-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* \
    && rm -rf /tmp/*

# Install Python
RUN curl -fsSL https://repo.huaweicloud.com/python/3.11.13/Python-3.11.13.tgz -o /tmp/Python-3.11.13.tgz && \
    tar -xf /tmp/Python-3.11.13.tgz -C /tmp && \
    cd /tmp/Python-3.11.13 && \
    mkdir -p /usr/local/python3.11.13/lib && \
    ./configure --enable-shared --enable-shared LDFLAGS="-Wl,-rpath /usr/local/python3.11.13/lib" --prefix=/usr/local/python3.11.13 && \
    make -j $(nproc) && \
    make altinstall && \
    ln -sf /usr/local/python3.11.13/bin/python3.11 /usr/local/python3.11.13/bin/python3 && \
    ln -sf /usr/local/python3.11.13/bin/pip3.11 /usr/local/python3.11.13/bin/pip3 && \
    ln -sf /usr/local/python3.11.13/bin/python3 /usr/local/python3.11.13/bin/python && \
    ln -sf /usr/local/python3.11.13/bin/pip3 /usr/local/python3.11.13/bin/pip && \
    rm -rf /tmp/*

# Stage 2: Install CANN
FROM python-installer AS cann-installer

ARG TARGETPLATFORM

RUN sed -i "s@https\\?://[^/]*/ubuntu-ports/\\?@http://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
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
        libblas3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Note: Install CANN runtime dependencies
RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
        attrs cython numpy==1.24.0 decorator sympy cffi pyyaml pathlib2 \
        psutil protobuf==3.20 scipy requests absl-py

# Note: Get the download link according to ARCH and download the installation package
RUN ARCH=$(case "${TARGETPLATFORM}" in \
        "linux/amd64") echo "x86_64" ;; \
        "linux/arm64") echo "aarch64" ;; \
        *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" && exit 1 ;; \
    esac) && \
    CANN_TOOLKIT_URL=https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C25B800TP028/Ascend-cann-toolkit_8.5.0.alpha002_linux-${ARCH}.run && \
    CANN_KERNELS_URL=https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C25B800TP028/Ascend-cann-kernels-910b_8.5.0.alpha002_linux-${ARCH}.run && \
    wget --quiet --header="Referer: https://www.hiascend.com/" ${CANN_TOOLKIT_URL} -O ~/Ascend-cann-toolkit.run && \
    wget --quiet --header="Referer: https://www.hiascend.com/" ${CANN_KERNELS_URL} -O ~/Ascend-cann-kernels.run

# Note: Install CANN Toolkit Development Kit Package
RUN chmod +x ~/Ascend-cann-toolkit.run && \
    ~/Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    rm -f ~/Ascend-cann-toolkit.run

# Note: Install CANN Kernels Operator Package
RUN chmod +x ~/Ascend-cann-kernels.run && \
    ~/Ascend-cann-kernels.run --quiet --install --install-for-all && \
    rm -f ~/Ascend-cann-kernels.run
    
# Stage 3: Copy results from previous stages
FROM swr.cn-southwest-2.myhuaweicloud.com/wuzhenqing/ubuntu:22.04 AS official-ubuntu

# Python Environment variables
ENV PATH=/usr/local/python3.11.13/bin:${PATH}

# Note: Toolkit Environment variables, obtained from /usr/local/Ascend/ascend-toolkit/set_env.sh
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common/:/usr/local/Ascend/driver/lib64/driver/:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/lib64:${ASCEND_TOOLKIT_HOME}/lib64/plugin/opskernel:${ASCEND_TOOLKIT_HOME}/lib64/plugin/nnengine:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe/op_tiling:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/tools/aml/lib64:${ASCEND_TOOLKIT_HOME}/tools/aml/lib64/plugin:$LD_LIBRARY_PATH
ENV PYTHONPATH=${ASCEND_TOOLKIT_HOME}/python/site-packages:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe:$PYTHONPATH
ENV PATH=${ASCEND_TOOLKIT_HOME}/bin:${ASCEND_TOOLKIT_HOME}/compiler/ccec_compiler/bin:${ASCEND_TOOLKIT_HOME}/tools/ccec_compiler/bin:$PATH
ENV ASCEND_AICPU_PATH=${ASCEND_TOOLKIT_HOME}
ENV ASCEND_OPP_PATH=${ASCEND_TOOLKIT_HOME}/opp
ENV TOOLCHAIN_HOME=${ASCEND_TOOLKIT_HOME}/toolkit
ENV ASCEND_HOME_PATH=${ASCEND_TOOLKIT_HOME}

SHELL [ "/bin/bash", "-c" ]

RUN sed -i "s@https\\?://[^/]*/ubuntu-ports/\\?@http://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        apt-transport-https \
        bash \
        build-essential \
        ca-certificates \
        clang \
        clangd \
        clang-format \
        cmake \
        curl \
        git \
        jq \
        libc6 \
        libnuma-dev \
        libsqlite3-dev \
        lld \
        llvm \
        ninja-build \
        unzip \
        vim \
        wget \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* \
    && rm -rf /tmp/*

COPY --from=cann-installer /usr/local/python3.11.13 /usr/local/python3.11.13
COPY --from=cann-installer /usr/local/Ascend /usr/local/Ascend
COPY --from=cann-installer /etc/Ascend /etc/Ascend

# Note: Set environment variables
RUN \
    CANN_TOOLKIT_ENV_FILE="/usr/local/Ascend/ascend-toolkit/set_env.sh" && \
    echo "source ${CANN_TOOLKIT_ENV_FILE}" >> /etc/profile && \
    echo "source ${CANN_TOOLKIT_ENV_FILE}" >> ~/.bashrc
    
ENTRYPOINT ["/bin/bash", "-c", "\
    source /usr/local/Ascend/ascend-toolkit/set_env.sh && \
    exec \"$@\"", "--"]

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

# Install Google Test using apt package manager
RUN sed -i "s@https\\?://[^/]*/ubuntu-ports/\\?@http://repo.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        libgtest-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build and install Google Test from source (libgtest-dev only provides source code)
RUN cd /usr/src/googletest && \
    cmake . && \
    cmake --build . && \
    cmake --install . --prefix /usr/local && \
    ldconfig && \
    rm -rf /usr/src/googletest

USER ma-user
WORKDIR /home/ma-user

RUN wget -qO- https://astral.sh/uv/install.sh | sh && \
    wget https://xmake.io/shget.text -O - | bash

# Configure pip and install Python packages
RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install attrs cython numpy==1.26.0 decorator sympy cffi pyyaml pathlib2 psutil protobuf==3.20 scipy requests absl-py && \
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu && \
    pip install setuptools torch-npu==2.7.1rc1
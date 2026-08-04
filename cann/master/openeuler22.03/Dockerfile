FROM openeuler/openeuler:22.03

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL
ARG PYTHON_VERSION=3.12.13

USER root

WORKDIR /root

# Put custom Python first in PATH. Do NOT add its lib to LD_LIBRARY_PATH —
# yum/dnf are Python-based and would break if libpython is overridden.
# libpython is resolved via rpath baked into the interpreter at build time.
ENV PATH=/usr/local/python${PYTHON_VERSION}/bin:/opt/openEuler/gcc-toolset-12/root/usr/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/openEuler/gcc-toolset-12/root/usr/lib64:${LD_LIBRARY_PATH}

RUN yum makecache && \
    yum update -y && \
    yum install -y \
        bzip2-devel \
        cmake \
        curl \
        expat-devel \
        gcc-toolset-12-* \
        gdbm-devel \
        libev-devel \
        libffi-devel \
        libpcap-devel \
        make \
        ncurses-devel \
        ninja-build \
        openssl-devel \
        readline-devel \
        sqlite-devel \
        systemtap-sdt-devel \
        tk-devel \
        wget \
        xz-devel \
        zlib-devel && \
    yum clean all && \
    rm -rf /var/cache/yum /tmp/*

# Build Python from source with rpath so yum/dnf keep using system libpython.
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

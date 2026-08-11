FROM openeuler/openeuler:24.03-lts

USER root
WORKDIR /root

RUN dnf install -y \
        bzip2-devel ca-certificates clang clang-tools-extra cmake curl \
        gcc gcc-c++ git lld llvm libffi-devel libxcrypt-devel \
        ncurses-devel libzstd-devel make ninja-build \
        openssl-devel pkgconf-pkg-config readline-devel sqlite-devel \
        wget xz xz-devel zlib-devel && \
    dnf clean all && rm -rf /var/cache/dnf

RUN wget -q https://repo.huaweicloud.com/python/3.11.15/Python-3.11.15.tar.xz && \
    tar -xf Python-3.11.15.tar.xz && cd Python-3.11.15 && \
    ./configure --enable-shared \
        LDFLAGS="-Wl,-rpath,/usr/local/python3.11.15/lib" \
        --prefix=/usr/local/python3.11.15 && \
    make -j"$(nproc)" && make altinstall && \
    ln -sf python3.11 /usr/local/python3.11.15/bin/python3 && \
    ln -sf pip3.11 /usr/local/python3.11.15/bin/pip3 && \
    ln -sf python3 /usr/local/python3.11.15/bin/python && \
    ln -sf pip3 /usr/local/python3.11.15/bin/pip && \
    cd /root && rm -rf Python-3.11.15 Python-3.11.15.tar.xz

ENV PATH=/usr/local/python3.11.15/bin:$PATH

# CANN's TBE code generator imports NumPy while compiling Ascend C kernels.
RUN python -m pip install --no-cache-dir \
        --index-url https://repo.huaweicloud.com/repository/pypi/simple \
        numpy==1.26.4

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL
ARG CANN_OPS_REF=master

RUN test -n "${CANN_TOOLKIT_URL}" && test -n "${CANN_OPS_URL}" && \
    groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget -q "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget -q "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    chmod +x Ascend-cann-toolkit.run Ascend-cann-ops.run && \
    ./Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    ./Ascend-cann-ops.run --quiet --install --install-for-all && \
    rm Ascend-cann-toolkit.run Ascend-cann-ops.run && \
    test -f /usr/local/Ascend/ascend-toolkit/set_env.sh && \
    echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc

RUN python -m pip install --no-cache-dir \
        --index-url https://repo.huaweicloud.com/repository/pypi/simple \
        absl-py attrs cffi cython decorator pathlib2 psutil \
        protobuf==3.20.3 pyyaml requests scipy sympy

# Compile an existing open-source operator; no device is required for this check.
RUN . /usr/local/Ascend/ascend-toolkit/set_env.sh && \
    git clone --depth 1 --branch "${CANN_OPS_REF}" https://gitee.com/ascend/cann-ops.git && \
    cd cann-ops && \
    bash build.sh -n add_custom -c ascend910b && \
    test -n "$(find build_out output -type f \( -name '*.run' -o -name '*.so' \) -print -quit 2>/dev/null)" && \
    cd /root && rm -rf cann-ops

CMD ["/bin/bash"]

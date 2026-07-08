FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:9.0.0-910b-ubuntu22.04-py3.11

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

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        btop \
        build-essential \
        ca-certificates \
        clang \
        clangd \
        cmake \
        curl \
        git \
        libedit-dev \
        libffi-dev \
        libfmt-dev \
        libncurses5-dev \
        libspdlog-dev \
        libxml2-dev \
        lld \
        neofetch \
        net-tools \
        ninja-build \
        openssh-server \
        patch \
        python3-dev \
        swig \
        tmux \
        unzip \
        vim \
        wget \
        xz-utils \
        zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /bin/bash /bin/sh

USER ma-user

WORKDIR /home/ma-user

RUN wget -q https://mirrors.nju.edu.cn/anaconda/miniconda/Miniconda3-py311_26.3.2-2-Linux-aarch64.sh && \
    bash Miniconda3-py311_26.3.2-2-Linux-aarch64.sh -b -p /home/ma-user/miniconda3 && \
    /home/ma-user/miniconda3/bin/conda init bash && \
    /home/ma-user/miniconda3/bin/conda tos accept && \
    /home/ma-user/miniconda3/bin/conda create -y -n pyasc python=3.11 && \
    /home/ma-user/miniconda3/bin/conda clean -afy && \
    rm Miniconda3-py311_26.3.2-2-Linux-aarch64.sh

ENV PATH=/home/ma-user/miniconda3/condabin:${PATH}
ENV CONDA_DEFAULT_ENV=pyasc

RUN conda run -n base pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    wget -q https://llvm-project.obs.cn-southwest-2.myhuaweicloud.com/llvm-project-19.1.7.src.tar.xz && \
    tar -xf llvm-project-19.1.7.src.tar.xz && \
    cd llvm-project-19.1.7.src && \
    conda run -n pyasc python -m pip install --no-cache-dir -r mlir/python/requirements.txt && \
    cmake -S llvm -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/home/ma-user/LLVM \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_ENABLE_LLD=ON \
        -DLLVM_ENABLE_PROJECTS="clang;mlir" \
        -DLLVM_TARGETS_TO_BUILD="AArch64" \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_INSTALL_UTILS=ON \
        -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
        -DPython3_EXECUTABLE=/home/ma-user/miniconda3/envs/pyasc/bin/python \
        -DPython3_FIND_STRATEGY=LOCATION && \
    cmake --build build -j $(nproc) && \
    cmake --install build && \
    cd /home/ma-user && \
    rm -rf llvm-project-19.1.7.src.tar.xz llvm-project-19.1.7.src

ENV LLVM_INSTALL_PREFIX=/home/ma-user/LLVM

RUN conda run -n pyasc python -m pip install --no-cache-dir \
        build \
        numpy==1.26.4 \
        pybind11 \
        pytest \
        pytest-xdist \
        pyyaml \
        rich \
        scikit-build-core \
        torch==2.9.0 \
        torch-npu==2.9.0 \
        torchaudio==2.9.0 \
        torchvision==0.24.0 \
        transformers
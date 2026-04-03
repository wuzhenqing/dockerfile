FROM ascendai/cann:8.5.1-a3-ubuntu22.04-py3.12

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

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        btop \
        build-essential \
        ca-certificates \
        clang \
        clang-format \
        clang-tidy \
        clangd \
        cmake \
        curl \
        dnsutils \
        fd-find \
        gdb \
        git \
        iputils-ping \
        jq \
        libfmt-dev \
        libspdlog-dev \
        llvm \
        man-db \
        neofetch \
        net-tools \
        ninja-build \
        openssh-server \
        patch \
        ripgrep \
        rsync \
        tmux \
        traceroute \
        tree \
        unzip \
        vim \
        wget \
        zip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    # replace sh by bash
    rm /bin/sh && ln -s /bin/bash /bin/sh

USER ma-user

WORKDIR /home/ma-user

RUN wget https://mirrors.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh && \
    bash Miniforge3-Linux-aarch64.sh -b -p /home/ma-user/miniforge3 && \
    /home/ma-user/miniforge3/bin/conda init bash && \
    /home/ma-user/miniforge3/bin/mamba shell init --shell bash --root-prefix /home/ma-user/miniforge3 && \
    rm Miniforge3-Linux-aarch64.sh

ENV PATH=/home/ma-user/miniforge3/bin:$PATH

RUN mamba create -n py311 python=3.11 -y && \
    mamba create -n py312 python=3.12 -y && \
    mamba run -n py311 python -m pip install --no-cache-dir \
        build \
        numpy==1.26.4 \
        pybind11==3.0.2 \
        pytest \
        pytest-xdist \
        pyyaml \
        rich \
        scikit-build-core \
        torch==2.9.0 \
        torch-npu==2.9.0 \
        torchaudio==2.9.0 \
        torchvision==0.24.0 \
        transformers && \
    mamba run -n py312 python -m pip install --no-cache-dir \
        build \
        numpy==1.26.4 \
        pybind11==3.0.2 \
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

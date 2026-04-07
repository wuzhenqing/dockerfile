FROM ascendai/cann:9.0.0-beta.2-910b-openeuler24.03-py3.11

ARG TARGETARCH

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

RUN yum install -y \
        autoconf \
        automake \
        cmake \
        curl \
        fmt \
        gcc \
        gcc-c++ \
        gcc-toolset-14-* \
        git \
        htop \
        kernel-devel \
        libtool \
        llvm-toolset-19* \
        make \
        ninja-build \
        pkg-config \
        spdlog \
        tmux \
        tree \
        vim \
        wget && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

# Enable GCC 14 and LLVM 19 toolsets by default
RUN echo "" >> ~/.bashrc && \
    echo "# Enable GCC Toolset 14" >> ~/.bashrc && \
    echo "source /opt/openEuler/gcc-toolset-14/enable" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "# Enable LLVM Toolset 19" >> ~/.bashrc && \
    echo "source /opt/openEuler/llvm-toolset-19/enable" >> ~/.bashrc

RUN wget https://mirrors.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh && \
    bash Miniforge3-Linux-aarch64.sh -b -p /root/miniforge3 && \
    /root/miniforge3/bin/conda init bash && \
    /root/miniforge3/bin/mamba shell init --shell bash --root-prefix /root/miniforge3 && \
    rm Miniforge3-Linux-aarch64.sh

ENV PATH=/root/miniforge3/bin:$PATH
ENV PIP_INDEX_URL=https://repo.huaweicloud.com/repository/pypi/simple

RUN mamba create -n py311 python=3.11 -y && \
    mamba run -n py311 python -m pip install --no-cache-dir \
        build \
        filecheck \
        lit \
        numpy==1.26.4 \
        pybind11==3.0.2 \
        pytest \
        pytest-xdist \
        pyyaml \
        rich \
        scikit-build-core \
        transformers && \
    mamba run -n py311 python -m pip install --no-cache-dir \
        -f https://mirrors.aliyun.com/pytorch-wheels/cpu/ \
        torch==2.9.0 \
        torchaudio==2.9.0 \
        torchvision==0.24.0 && \
    mamba run -n py311 python -m pip install --no-cache-dir \
        torch-npu==2.9.0

RUN mamba create -n py312 python=3.12 -y && \
    mamba run -n py312 python -m pip install --no-cache-dir \
        build \
        filecheck \
        lit \
        numpy==1.26.4 \
        pybind11==3.0.2 \
        pytest \
        pytest-xdist \
        pyyaml \
        rich \
        scikit-build-core \
        transformers && \
    mamba run -n py312 python -m pip install --no-cache-dir \
        -f https://mirrors.aliyun.com/pytorch-wheels/cpu/ \
        torch==2.9.0 \
        torchaudio==2.9.0 \
        torchvision==0.24.0 && \
    mamba run -n py312 python -m pip install --no-cache-dir \
        torch-npu==2.9.0
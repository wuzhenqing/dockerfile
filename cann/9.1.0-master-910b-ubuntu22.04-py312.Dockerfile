FROM ubuntu:22.04

USER root

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

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
        clangd \
        cmake \
        curl \
        git \
        libfmt-dev \
        libspdlog-dev \
        llvm \
        neofetch \
        net-tools \
        ninja-build \
        openssh-server \
        patch \
        python3 \
        python3-pip \
        rsync \
        tmux \
        tree \
        unzip \
        vim \
        wget \
        zip && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    # replace sh by bash
    rm /bin/sh && ln -s /bin/bash /bin/sh

RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/20260610120325172/Ascend-cann-toolkit_9.1.0_linux-aarch64.run && \
    wget --quiet https://ascend.devcloud.huaweicloud.com/artifactory/cann-run-mirror/software/master/20260610120325172/Ascend-cann-910b-ops_9.1.0_linux-aarch64.run && \
    bash ./Ascend-cann-toolkit_9.1.0_linux-aarch64.run --quiet --install --install-for-all && \
    bash ./Ascend-cann-910b-ops_9.1.0_linux-aarch64.run --quiet --install --install-for-all && \
    echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /home/ma-user/.bashrc && \
    echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc && \
    rm ./Ascend-cann-toolkit_9.1.0_linux-aarch64.run && \
    rm ./Ascend-cann-910b-ops_9.1.0_linux-aarch64.run

USER ma-user

WORKDIR /home/ma-user

RUN wget https://mirrors.nju.edu.cn/anaconda/miniconda/Miniconda3-py310_26.3.2-2-Linux-aarch64.sh && \
    bash Miniconda3-py310_26.3.2-2-Linux-aarch64.sh -b -p /home/ma-user/miniconda3 && \
    /home/ma-user/miniconda3/bin/conda init bash && \
    /home/ma-user/miniconda3/bin/conda tos accept && \
    rm Miniconda3-py310_26.3.2-2-Linux-aarch64.sh

ENV PATH=/home/ma-user/miniconda3/condabin:$PATH

RUN conda create -y -n py312 python=3.12 && \
    conda run -n py312 pip config set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    conda run -n py312 pip install --no-cache-dir \
        build \
        cmake==3.28.4 \
        loguru \
        numpy==1.26.4 \
        pybind11 \
        pytest \
        pytest-xdist \
        pyyaml \
        rich \
        scikit-build-core \
        torch==2.10.0 \
        torch-npu==2.10.0 \
        torchaudio==2.10.0 \
        torchvision==0.25.0 \
        transformers && \
    echo 'conda activate py312' >> /home/ma-user/.bashrc

CMD ["/bin/bash"]
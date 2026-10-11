FROM ascendai/cann:9.2.0-beta.2-910b-ubuntu22.04-py3.12-devel

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

USER ma-user

WORKDIR /home/ma-user

RUN wget https://mirrors.nju.edu.cn/anaconda/miniconda/Miniconda3-py310_26.3.2-2-Linux-aarch64.sh && \
    bash Miniconda3-py310_26.3.2-2-Linux-aarch64.sh -b -p /home/ma-user/miniconda3 && \
    /home/ma-user/miniconda3/bin/conda init bash && \
    /home/ma-user/miniconda3/bin/conda tos accept && \
    rm Miniconda3-py310_26.3.2-2-Linux-aarch64.sh

ENV PATH=/home/ma-user/miniconda3/condabin:$PATH
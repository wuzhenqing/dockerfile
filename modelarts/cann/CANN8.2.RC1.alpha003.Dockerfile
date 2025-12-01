FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.2.rc1.alpha003-910b-ubuntu22.04-py3.11

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
    chmod -R 750 /home/ma-user && \
    chmod -R 777 /usr/local/Ascend

# Configure apt sources and install system packages
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i "s@http://.*ports.ubuntu.com@http://repo.huaweicloud.com/ubuntu-ports@g" /etc/apt/sources.list && \
    sed -i "s@http://.*ports.ubuntu.com@http://repo.huaweicloud.com/ubuntu-ports@g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install sudo build-essential vim git cmake -y && \
    apt-get install llvm clang clangd clang-format ninja-build -y && \
    apt-get install libeigen3-dev libboost-all-dev -y && \
    apt-get install btop neofetch net-tools zip wget curl openssh-server -y && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

USER ma-user

WORKDIR /home/ma-user

# Install Miniconda and configure environment with PyTorch and torch-npu
RUN echo "source /usr/local/Ascend/ascend-toolkit/latest/bin/setenv.bash" >> /home/ma-user/.bashrc && \
    wget --quiet https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py311_25.5.1-0-Linux-aarch64.sh && \
    bash Miniconda3-py311_25.5.1-0-Linux-aarch64.sh -b -p /home/ma-user/miniconda3 && \
    rm -rf Miniconda3-py311_25.5.1-0-Linux-aarch64.sh && \
    source /home/ma-user/miniconda3/bin/activate && \
    conda init bash && \
    pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install attrs cython numpy==1.26.0 decorator sympy cffi pyyaml pathlib2 psutil protobuf==3.20 scipy requests absl-py && \
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip install setuptools torch-npu==2.7.1rc1

FROM ascendai/cann:8.3.rc1.alpha003-910b-ubuntu22.04-py3.11

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

# Configure apt sources and install system packages
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then \
        sed -i "s@http://[^/]*/ubuntu-ports@https://mirrors.huaweicloud.com/ubuntu-ports@g" /etc/apt/sources.list && \
        sed -i "s@http://[^/]*/ubuntu/@https://mirrors.huaweicloud.com/ubuntu-ports/@g" /etc/apt/sources.list; \
    else \
        sed -i "s@http://[^/]*/ubuntu-ports@https://mirrors.huaweicloud.com/ubuntu@g" /etc/apt/sources.list && \
        sed -i "s@http://[^/]*/ubuntu/@https://mirrors.huaweicloud.com/ubuntu/@g" /etc/apt/sources.list; \
    fi && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install sudo build-essential vim git cmake -y && \
    apt-get install clangd clang-format ninja-build -y && \
    apt-get install btop neofetch net-tools zip wget curl openssh-server -y && \
    apt-get clean -y && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

USER ma-user

# Configure pip and install Python packages
RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install attrs cython numpy==1.26.0 decorator sympy cffi pyyaml pathlib2 psutil protobuf==3.20 scipy requests absl-py && \
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cpu && \
    pip install setuptools torch-npu==2.7.1rc1

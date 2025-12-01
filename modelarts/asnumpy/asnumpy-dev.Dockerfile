FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.3.rc1.alpha002-910b-ubuntu22.04-py3.11

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
    sed -i "s@http://.*ports.ubuntu.com@https://mirrors.huaweicloud.com@g" /etc/apt/sources.list && \
    sed -i "s@http://.*security.ubuntu.com@https://mirrors.huaweicloud.com@g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install sudo build-essential vim git cmake -y && \
    apt-get install llvm clang clangd clang-format ninja-build -y && \
    apt-get install libeigen3-dev libboost-all-dev -y && \
    apt-get install btop neofetch net-tools zip wget curl openssh-server -y && \
    rm /bin/sh && ln -s /bin/bash /bin/sh

USER ma-user

WORKDIR /home/ma-user

# Configure pip and install Python packages for asnumpy development
RUN pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com && \
    pip install numpy pytest

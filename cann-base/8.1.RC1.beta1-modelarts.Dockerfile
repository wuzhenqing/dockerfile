FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.1.rc1-910b-ubuntu22.04-py3.11

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
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:xmake-io/xmake && \
    apt-get update && \
    apt-get install sudo build-essential vim git cmake xmake llvm clang clangd ninja-build -y && \
    apt-get install btop neofetch zip wget curl openssh-server -y && \
    apt-get install python3 python3-dev python3-pip -y && \
    apt-get install libsqlite3-dev zlib1g-dev libssl-dev libffi-dev libbz2-dev liblzma-dev ca-certificates -y && \
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    pip config --user set global.index https://repo.huaweicloud.com/repository/pypi && \
    pip config --user set global.index-url https://repo.huaweicloud.com/repository/pypi/simple && \
    pip config --user set global.trusted-host repo.huaweicloud.com



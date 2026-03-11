FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.5.1-a3-openeuler24.03-py3.11

USER root

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
        llvm-toolset-19-* \
        make \
        ninja-build \
        pkg-config \
        spdlog \
        tmux \
        tree \
        vim \
        wget

USER ma-user

WORKDIR /home/ma-user

RUN wget https://mirrors.nju.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-aarch64.sh && \
    bash Miniconda3-latest-Linux-aarch64.sh -b -p /home/ma-user/miniconda3 && \
    /home/ma-user/miniconda3/bin/conda init bash && \
    rm Miniconda3-latest-Linux-aarch64.sh

RUN echo "" >> ~/.bashrc && \
    echo "# Enable GCC Toolset 14" >> ~/.bashrc && \
    echo "source /opt/openEuler/gcc-toolset-14/enable" >> ~/.bashrc && \
    echo "" >> ~/.bashrc && \
    echo "# Enable LLVM Toolset 19" >> ~/.bashrc && \
    echo "source /opt/openEuler/llvm-toolset-19/enable" >> ~/.bashrc

FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:8.5.1-910b-openeuler24.03-py3.11

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

RUN dnf install -y \
        ccache \
        cmake \
        curl \
        findutils \
        fmt-devel \
        gcc-toolset-14-* \
        git \
        gzip \
        libffi-devel \
        make \
        ninja-build \
        openssl-devel \
        pkgconfig \
        spdlog-devel \
        tar \
        unzip \
        wget \
        which \
        xz \
        zlib-devel && \
    yum clean all && \
    echo 'source /opt/openEuler/gcc-toolset-14/enable' >> /root/.bashrc && \
    echo 'source /opt/openEuler/gcc-toolset-14/enable' >> /home/ma-user/.bashrc

USER ma-user

WORKDIR /home/ma-user

RUN wget https://mirrors.nju.edu.cn/github-release/conda-forge/miniforge/LatestRelease/Miniforge3-Linux-aarch64.sh && \
    bash Miniforge3-Linux-aarch64.sh -b -p /home/ma-user/miniforge3 && \
    /home/ma-user/miniforge3/bin/conda init bash && \
    rm Miniforge3-Linux-aarch64.sh

ENV PATH=/home/ma-user/miniforge3/bin:$PATH

RUN conda create -n py311 python=3.11 -y && \
    conda create -n py312 python=3.12 -y && \
    conda run -n py311 python -m pip install --no-cache-dir \
        build \
        numpy==1.26.4 \
        pybind11==3.0.2 \
        pytest \
        pytest-xdist \
        pyyaml \
        scikit-build-core \
        torch==2.9.0 \
        torchvision \
        torch-npu==2.9.0 && \
    conda run -n py312 python -m pip install --no-cache-dir \
        build \
        numpy==1.26.4 \
        pybind11==3.0.2 \
        pytest \
        pytest-xdist \
        pyyaml \
        scikit-build-core \
        torch==2.9.0 \
        torchvision \
        torch-npu==2.9.0

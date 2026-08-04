FROM ubuntu:22.04

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL

USER root

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        build-essential \
        ca-certificates \
        cmake \
        ninja-build \
        wget && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    bash Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    bash Ascend-cann-ops.run --quiet --install --install-for-all && \
    rm -f Ascend-cann-toolkit.run Ascend-cann-ops.run && \
    echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc

CMD ["/bin/bash"]

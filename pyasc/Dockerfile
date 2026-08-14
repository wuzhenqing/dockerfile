# Copyright (c) 2026 wuzhenqing
# SPDX-License-Identifier: MIT

# Layer CANN toolkit + ops on a prebuilt LLVM 19.1.7 image
# (CPython 3.11.15 + Clang/MLIR). Override LLVM_IMAGE for each distro.
ARG LLVM_IMAGE=swr.ap-southeast-1.myhuaweicloud.com/wuzhenqing/llvm:19.1.7-ubuntu24.04
# hadolint ignore=DL3006
FROM ${LLVM_IMAGE}

USER root
WORKDIR /root

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL

# HwHiAiUser is required by the CANN installers; the container still runs as root.
RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    chmod +x Ascend-cann-toolkit.run && \
    chmod +x Ascend-cann-ops.run && \
    ./Ascend-cann-toolkit.run --quiet --install && \
    ./Ascend-cann-ops.run --quiet --install && \
    echo 'source /usr/local/Ascend/cann/set_env.sh' >> /root/.bashrc && \
    rm Ascend-cann-toolkit.run Ascend-cann-ops.run

CMD ["/bin/bash"]

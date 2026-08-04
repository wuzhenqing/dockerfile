FROM openeuler/openeuler:22.03

ARG CANN_TOOLKIT_URL
ARG CANN_OPS_URL

USER root

WORKDIR /root

RUN yum makecache && \
    yum update -y && \
    yum install -y \
        cmake \
        gcc-toolset-12-* \
        make \
        ninja-build \
        wget && \
    yum clean all

ENV PATH=/opt/openEuler/gcc-toolset-12/root/usr/bin/:$PATH \
    LD_LIBRARY_PATH=/opt/openEuler/gcc-toolset-12/root/usr/lib64/:$LD_LIBRARY_PATH

RUN groupadd HwHiAiUser && \
    useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash && \
    wget --quiet "${CANN_TOOLKIT_URL}" -O Ascend-cann-toolkit.run && \
    wget --quiet "${CANN_OPS_URL}" -O Ascend-cann-ops.run && \
    bash Ascend-cann-toolkit.run --quiet --install --install-for-all && \
    bash Ascend-cann-ops.run --quiet --install --install-for-all && \
    rm -f Ascend-cann-toolkit.run Ascend-cann-ops.run && \
    echo 'source /usr/local/Ascend/ascend-toolkit/set_env.sh' >> /root/.bashrc

CMD ["/bin/bash"]

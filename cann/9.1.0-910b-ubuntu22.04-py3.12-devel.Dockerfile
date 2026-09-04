FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:9.1.0-910b-ubuntu22.04-py3.12-devel

USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
		build-essential \
		openssh-server \
		tzdata

# （必要）修改SSH配置
RUN mkdir -p /var/run/sshd && \
    sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config 

# （可选）安装miniconda，如需其他版本：https://repo.anaconda.com/miniconda/
RUN cd /root && wget -q https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-aarch64.sh \
    && bash ./Miniconda3-latest-Linux-aarch64.sh -b -f -p /root/miniconda3 \
    && rm -f ./Miniconda3-latest-Linux-aarch64.sh \
    && echo "PATH=/root/miniconda3/bin:$PATH" >> /root/.bashrc

# （可选）设置语言和时区
RUN export DEBIAN_FRONTEND=noninteractive && \
    locale-gen zh_CN zh_CN.GB18030 zh_CN.GBK zh_CN.UTF-8 en_US.UTF-8 && \
    update-locale && \
    echo "LANG=en_US.UTF-8" >> /etc/profile && \
    echo "LANGUAGE=en_US:en" >> /etc/profile && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/profile && \
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' >/etc/timezone
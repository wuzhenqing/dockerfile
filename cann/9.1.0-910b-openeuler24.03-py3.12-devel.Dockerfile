FROM swr.cn-south-1.myhuaweicloud.com/ascendhub/cann:9.1.0-910b-openeuler24.03-py3.12-devel

USER root

RUN dnf update -y && \
	dnf groupinstall -y "Development Tools" && \
    dnf install -y openssh-server glibc-locale-source

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
RUN localedef --no-archive -c -i zh_CN -f GB2312 zh_CN.GB2312 && \
    localedef --no-archive -c -i zh_CN -f GB18030 zh_CN.GB18030 && \
    localedef --no-archive -c -i zh_CN -f GBK zh_CN.GBK && \
    localedef --no-archive -c -i zh_CN -f UTF-8 zh_CN.UTF-8 && \
    localedef --no-archive -c -i en_US -f UTF-8 en_US.UTF-8 && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
    echo "LANG=en_US.UTF-8" >> /etc/profile && \
    echo "LANGUAGE=en_US:en" >> /etc/profile && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/profile && \
    cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' >/etc/timezone
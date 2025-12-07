#!/bin/bash

echo ">>> 正在加载 Ascend 环境变量..."
source /usr/local/Ascend/ascend-toolkit/set_env.sh
source /usr/local/Ascend/nnal/atb/set_env.sh
echo ">>> Ascend 环境变量加载完成。"

SSH_DIR="/root/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -n "$HOST_SSH_PUB_KEY" ]; then
  echo ">>> 检测到宿主机公钥 (HOST_SSH_PUB_KEY)，正在添加到 authorized_keys..."
  echo "$HOST_SSH_PUB_KEY" >> "$AUTHORIZED_KEYS"
  echo ">>> 宿主机公钥已添加。"
fi

if [ -f "/tmp/host_ssh_key.pub" ]; then
  echo ">>> 检测到挂载的公钥文件 (/tmp/host_ssh_key.pub)，正在添加到 authorized_keys..."
  cat "/tmp/host_ssh_key.pub" >> "$AUTHORIZED_KEYS"
  echo ">>> 挂载的公钥已添加。"
fi

if [ ! -f "$SSH_DIR/id_rsa" ]; then
  echo ">>> 容器内未找到 SSH 密钥，正在生成新的密钥对..."
  ssh-keygen -t rsa -b 4096 -f "$SSH_DIR/id_rsa" -N "" -q
  echo "=================================================================="
  echo "!!! 容器 SSH 密钥对已生成 !!!"
  echo ">>> 请将以下【私钥】内容复制并保存为文件（例如：container_rsa），分发给你的团队成员："
  echo "=================================================================="
  cat "$SSH_DIR/id_rsa"
  echo "=================================================================="
  echo "!!! 对应的公钥如下（已自动添加到 authorized_keys）："
  cat "$SSH_DIR/id_rsa.pub"
  echo "=================================================================="
fi

chmod 600 "$AUTHORIZED_KEYS"

echo ">>> 正在启动 SSH 服务..."
/usr/sbin/sshd -D &

echo ">>> 初始化完成。容器将保持运行，SSH 服务已就绪。"
tail -f /dev/null


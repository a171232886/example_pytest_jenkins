#!/bin/bash

# 备份原有的sources.list文件
echo "备份原有的sources.list为sources.list.bak..."
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 写入清华源配置
echo "写入清华源配置..."
cat > /etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
EOF

# 更新软件包列表
echo "更新软件包列表..."
apt update

echo "清华源配置完成！"


apt update
apt install -y ./allure_2.34.1-1_all.deb

pip install -i https://pypi.tuna.tsinghua.edu.cn/simple  -r requirements.txt


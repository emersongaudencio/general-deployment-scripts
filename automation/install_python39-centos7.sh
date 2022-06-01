#!/bin/bash
#### install python3 #####
cd /opt
yum install wget gcc openssl-devel libffi-devel bzip2-devel -y
wget https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz
tar xzvf ./Python-3.9.13.tgz
cd ./Python-3.9.13
./configure --enable-optimizations
make altinstall

python3.9 --version
pip3.9 --version
/usr/local/bin/python3.9 -m pip install --upgrade pip
# pip3.9 install awscli

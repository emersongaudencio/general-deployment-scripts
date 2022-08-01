#!/bin/bash
#### install awscli #####
verify_awscli=`aws --version`
if [[ "${verify_awscli}" == "aws"* ]] ; then
  echo "$verify_awscli is installed!"
  echo "AWSCLI-Path: $(which aws)"
else
  yum -y install unzip
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  source ~/.bashrc
  aws --version
  echo "AWSCLI-Path: $(which aws)"
fi

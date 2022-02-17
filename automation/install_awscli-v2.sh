#!/bin/bash
#### install python3 #####
verify_python=`rpm -qa | grep python3-3`
if [[ "${verify_python}" == "python3-3"* ]] ; then
   echo "$verify_python is installed!"
else
   yum -y install python3 unzip
fi

#### install awscli #####
verify_awscli=`aws --version`
if [[ "${verify_awscli}" == "aws"* ]] ; then
  echo "$verify_awscli is installed!"
  echo "AWSCLI-Path: $(which aws)"
else
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  source ~/.bashrc
  aws --version
  echo "AWSCLI-Path: $(which aws)"
fi

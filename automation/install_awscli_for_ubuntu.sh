#!/bin/bash
#### install python3 #####
verify_python=$(dpkg -l | awk '{print $2}' | grep python3-distutils | awk 'NR==1{print $1}')
if [[ "${verify_python}" == "python3"* ]] ; then
   echo "$verify_python is installed!"
else
   ### installation git client via apt ####
   apt-get update -y
   apt-get install python3 -y
   apt-get install python3-distutils -y
   apt-get install python3-venv -y
   apt-get install unzip -y
   apt-get install curl -y
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
  source /etc/profile
  aws --version
  echo "AWSCLI-Path: $(which aws)"
fi

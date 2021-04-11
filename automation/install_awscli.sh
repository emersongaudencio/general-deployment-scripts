#!/bin/bash
#### install python3 #####
verify_python=`rpm -qa | grep python3-3`
if [[ "${verify_python}" == "python3-3"* ]] ; then
   echo "$verify_python is installed!"
else
   yum -y install python3
fi

#### install pip #####
verify_pip=`pip -V`
if [[ "${verify_pip}" == "pip"* ]] ; then
   echo "$verify_pip is installed!"
   echo "Pip-Path: $(which pip)"
else
   curl -sS https://bootstrap.pypa.io/get-pip.py | python3
   source ~/.bashrc
   pip -V
   echo "Pip-Path: $(which pip)"
fi

#### install awscli #####
verify_awscli=`aws --version`
if [[ "${verify_awscli}" == "aws"* ]] ; then
  echo "$verify_awscli is installed!"
  echo "AWSCLI-Path: $(which aws)"
else
  python3 -m pip install awscli
  source ~/.bashrc
  aws --version
  echo "AWSCLI-Path: $(which aws)"
fi

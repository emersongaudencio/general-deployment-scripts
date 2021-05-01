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
fi

#### install pip #####
verify_pip=`pip -V`
if [[ "${verify_pip}" == "pip"* ]] ; then
   echo "$verify_pip is installed!"
   echo "Pip-Path: $(which pip)"
else
   curl -sS https://bootstrap.pypa.io/get-pip.py | python3
   source /etc/profile
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
  source /etc/profile
  aws --version
  echo "AWSCLI-Path: $(which aws)"
fi

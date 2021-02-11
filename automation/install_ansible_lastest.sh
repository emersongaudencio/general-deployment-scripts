#!/bin/bash
#### install python3 #####
verify_python=`rpm -qa | grep python-3`
if [[ "${verify_python}" == "python-3"* ]] ; then
   echo "$verify_python is installed!"
else
   yum -y install python3
fi

#### install git #####
verify_git=`rpm -qa | grep git-1`
if [[ "${verify_git}" == "git"* ]] ; then
   echo "$verify_git is installed!"
else
   yum install git -y
fi

#### install pip #####
verify_pip=`pip -V`
if [[ "${verify_pip}" == "pip"* ]] ; then
   echo "$verify_pip is installed!"
else
   curl -sS https://bootstrap.pypa.io/get-pip.py | python3
fi

#### install ansible #####
verify_ansible=`ansible --version`
if [[ "${verify_ansible}" == "ansible"* ]] ; then
  echo "$verify_ansible is installed!"
else
  python3 -m pip install ansible
  ansible --version
fi

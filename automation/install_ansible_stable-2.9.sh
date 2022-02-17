#!/bin/bash
#### install python3 #####
verify_python=`rpm -qa | grep python3-3`
if [[ "${verify_python}" == "python3-3"* ]] ; then
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
   echo "Pip-Path: $(which pip)"
else
   verify_python3_version=`python3 --version`
   if [[ "${verify_python3_version}" == "Python 3.6"* ]] ; then
     curl -sS https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3
   else
     curl -sS https://bootstrap.pypa.io/get-pip.py | python3
     source ~/.bashrc
     pip -V
     echo "Pip-Path: $(which pip)"
   fi
fi

#### install ansible #####
verify_ansible=`ansible --version`
if [[ "${verify_ansible}" == "ansible"* ]] ; then
  echo "$verify_ansible is installed!"
  echo "Ansible-Path: $(which ansible)"
else
  python3 -m pip install https://github.com/ansible/ansible/archive/stable-2.9.tar.gz
  source ~/.bashrc
  ansible --version
  echo "Ansible-Path: $(which ansible)"
fi

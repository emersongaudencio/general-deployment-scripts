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
fi

#### install git #####
verify_git=$(dpkg -l | awk '{print $2}' | grep git | awk 'NR==1{print $1}')
if [[ "${verify_git}" == "git"* ]] ; then
   echo "$verify_git is installed!"
else
   ### installation git client via apt ####
   apt-get update -y
   apt install git -y
fi

#### install pip #####
verify_pip=`pip -V`
if [[ "${verify_pip}" == "pip"* ]] ; then
   echo "$verify_pip is installed!"
   echo "Pip-Path: $(which pip)"
else
   curl -sS https://bootstrap.pypa.io/get-pip.py | python3
   exec "$BASH"
   pip -V
   echo "Pip-Path: $(which pip)"
fi

#### install ansible #####
verify_ansible=`ansible --version`
if [[ "${verify_ansible}" == "ansible"* ]] ; then
  echo "$verify_ansible is installed!"
  echo "Ansible-Path: $(which ansible)"
else
  python3 -m pip install https://github.com/ansible/ansible/archive/stable-2.10.tar.gz
  exec "$BASH"
  ansible --version
  echo "Ansible-Path: $(which ansible)"
fi

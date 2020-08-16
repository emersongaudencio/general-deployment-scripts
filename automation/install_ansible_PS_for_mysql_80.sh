#!/bin/bash
#### install python2 #####
verify_python=`rpm -qa | grep python-2.7`
if [[ "${verify_python}" == "python-2.7"* ]] ; then
echo "$verify_python is installed!"
else
   sudo yum install python -y
fi

#### install git #####
verify_git=`rpm -qa | grep git-1`
if [[ "${verify_git}" == "git"* ]] ; then
echo "$verify_git is installed!"
else
   sudo yum install git -y
fi

#### install pip #####
verify_pip=`pip -V`
if [[ "${verify_pip}" == "pip"* ]] ; then
echo "$verify_pip is installed!"
else
   curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python
fi

#### install ansible #####
verify_ansible=`ansible --version`
if [[ "${verify_ansible}" == "ansible"* ]] ; then
echo "$verify_ansible is installed!"
else
  sudo pip install ansible --upgrade
  ansible --version
fi

cd /opt
git clone https://github.com/emersongaudencio/ansible-percona-for-mysql-install-standalone.git
cd ansible-percona-for-mysql-install-standalone/ansible
sudo sh run_mysql_install.sh dblocalhost 80

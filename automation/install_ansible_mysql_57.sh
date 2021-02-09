#!/bin/bash
#### install python3 #####
verify_python=`rpm -qa | grep python-3`
if [[ "${verify_python}" == "python-3"* ]] ; then
   echo "$verify_python is installed!"
   #### verify python support packages ####
   verify_PyYAML=`rpm -qa | grep PyYAML`
   if [[ "${verify_PyYAML}" == "PyYAML"* ]] ; then
      echo "$verify_PyYAML is installed!"
   else
      yum -y install PyYAML libyaml python-babel  python-cffi  python-enum34 python-idna python-jinja2 python-markupsafe python-paramiko  python-ply  python-pycparser python-six python2-cryptography
   fi
else
   yum -y install python3
   yum -y install PyYAML libyaml python-babel  python-cffi  python-enum34 python-idna python-jinja2 python-markupsafe python-paramiko  python-ply  python-pycparser python-six python2-cryptography
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
   curl -sS https://bootstrap.pypa.io/get-pip.py | python3
fi

#### install ansible #####
verify_ansible=`ansible --version`
if [[ "${verify_ansible}" == "ansible"* ]] ; then
  echo "$verify_ansible is installed!"
else
  pip install ansible --upgrade
  ansible --version
fi

cd /opt
git clone https://github.com/emersongaudencio/ansible-mysql-install-standalone.git
cd ansible-mysql-install-standalone/ansible
sh run_mysql_install.sh dblocalhost 57

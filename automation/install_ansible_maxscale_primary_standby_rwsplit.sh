#!/bin/bash
#### install python2 #####
verify_python=`rpm -qa | grep python-2.7`
if [[ "${verify_python}" == "python-2.7"* ]] ; then
   echo "$verify_python is installed!"
   #### verify python support packages ####
   verify_PyYAML=`rpm -qa | grep PyYAML`
   if [[ "${verify_PyYAML}" == "PyYAML"* ]] ; then
      echo "$verify_PyYAML is installed!"
   else
      sudo yum -y install PyYAML libyaml python-babel  python-cffi  python-enum34 python-idna python-jinja2 python-markupsafe python-paramiko  python-ply  python-pycparser python-six python2-cryptography
   fi
else
   sudo yum -y install python
   sudo yum -y install PyYAML libyaml python-babel  python-cffi  python-enum34 python-idna python-jinja2 python-markupsafe python-paramiko  python-ply  python-pycparser python-six python2-cryptography
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
git clone https://github.com/emersongaudencio/ansible-maxscale-for-mariadb.git
cd ansible-maxscale-for-mariadb
sudo sh run_maxscale.sh proxy-local 0 "maxscalechk" "Test123?dba" "monitor_user" "Test123?dba" "dbprimary01.replication.local" "dbstandby01.replication.local"
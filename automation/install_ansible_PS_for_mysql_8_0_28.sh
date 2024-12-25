#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh -o install_ansible_latest.sh
sh install_ansible_latest.sh

### mysql install ###
if [[ -d "/opt/ansible-percona-for-mysql-install-standalone" ]] ; then
  echo "Directory /opt/ansible-percona-for-mysql-install-standalone exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-percona-for-mysql-install-standalone.git
  cd ansible-percona-for-mysql-install-standalone/ansible
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_mysql_install.sh
  sudo sh run_mysql_install.sh dblocalhost 80 "8.0.28"
fi

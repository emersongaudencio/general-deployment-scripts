#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh -o install_ansible_latest.sh
sh install_ansible_latest.sh

### mariadb install ###
if [[ -d "/opt/ansible-mariadb-install-standalone" ]] ; then
  echo "Directory /opt/ansible-mariadb-install-standalone exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-mariadb-install-standalone.git
  cd ansible-mariadb-install-standalone/ansible
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_mariadb_install.sh
  sh run_mariadb_install.sh dblocalhost 102
fi

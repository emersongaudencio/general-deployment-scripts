#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh -o install_ansible_latest.sh
sh install_ansible_latest.sh

### postgresql install ###
if [[ -d "/opt/ansible-postgresql-install-standalone" ]] ; then
  echo "Directory /opt/ansible-postgresql-install-standalone exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-postgresql-install-standalone.git
  cd ansible-postgresql-install-standalone/ansible
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_postgresql_install.sh
  sh run_postgresql_install.sh dblocalhost 96
fi

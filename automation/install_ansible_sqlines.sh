#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.10.sh -o install_ansible_stable-2.10.sh
sh install_ansible_stable-2.10.sh

### mariadb install ###
if [[ -d "/opt/ansible-oracle-to-mariadb-migration" ]] ; then
  echo "Directory /opt/ansible-oracle-to-mariadb-migration exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-oracle-to-mariadb-migration.git
  cd ansible-oracle-to-mariadb-migration
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_sqlines.sh
  bash run_sqlines.sh sqlines-local migration
fi

#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh -o install_ansible_latest.sh
sh install_ansible_latest.sh

### maxscale install ###
if [[ -d "/opt/ansible-maxscale-for-mariadb" ]] ; then
  echo "Directory /opt/ansible-maxscale-for-mariadb exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-maxscale-for-mariadb.git
  cd ansible-maxscale-for-mariadb
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_maxscale.sh
  sh run_maxscale.sh proxy-local 1 "maxscalechk" "Test123?dba" "monitor_user" "Test123?dba" "primary.db.local" "primary.db.local"
fi

#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh -o install_ansible_latest.sh
sh install_ansible_latest.sh

### proxysql install ###
if [[ -d "/opt/ansible-proxysql-for-mysql" ]] ; then
  echo "Directory /opt/ansible-proxysql-for-mysql exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-proxysql-for-mysql.git
  cd ansible-proxysql-for-mysql
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_proxysql.sh
  sh run_proxysql.sh proxy-local 0 "proxysqlchk" "Test123?dba"
fi

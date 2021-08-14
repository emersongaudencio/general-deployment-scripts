#!/bin/bash
### pre-reqs install ###
cd /opt
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.10.sh -o install_ansible_stable-2.10.sh
sh install_ansible_stable-2.10.sh

### pmm-server install ###
if [[ -d "/opt/ansible-pmm-install-standalone" ]] ; then
  echo "Directory /opt/ansible-pmm-install-standalone exists."
else
  cd /opt
  git clone https://github.com/emersongaudencio/ansible-pmm-install-standalone.git
  cd ansible-pmm-install-standalone
  sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_pmm_server.sh
  sh run_pmm_server.sh pmm-server-local
fi

#!/bin/bash
# ansible
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh | bash

# awscli
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_awscli-v2.sh | bash

# terraform
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_terraform.sh | bash

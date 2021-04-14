#!/bin/bash
# ansible
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.9.sh | bash

# awscli
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_awscli.sh | bash

# terraform
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_terraform.sh | bash

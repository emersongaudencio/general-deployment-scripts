#!/bin/bash
# mariadb example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mariadb_105.sh | bash

# mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mysql_57.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_80.sh | bash

# ansible example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.9.sh | bash

# ansible for ubuntu
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest_for_ubuntu.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.9_for_ubuntu.sh | bash

# awscli example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_awscli.sh | bash

# terraform example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_terraform.sh | bash

# centos devops tools
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/centos_devops_install.sh | bash

# ubuntu devops tools
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/ubuntu_devops_install.sh | bash

# install mysql 8.0.23 linux64 minimal
cd /usr/local/bin/
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/mysql-8.0.23-linux64-minimal.tgz -o mysql-8.0.23-linux64-minimal.tgz
tar -xzvf mysql-8.0.23-linux64-minimal.tgz
ln -r -s mysql-8.0.23-linux64-minimal/bin/mysql mysql
ln -r -s mysql-8.0.23-linux64-minimal/bin/mysqldump mysqldump

# install mysql 8.0.23 linux64 minimal
cd /usr/local/bin/
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/mysqlclient8.tgz -o mysqlclient8.tgz
tar -xzvf mysqlclient8.tgz
ln -r -s mysqlclient8/bin/mysql mysql
ln -r -s mysqlclient8/bin/mysqldump mysqldump

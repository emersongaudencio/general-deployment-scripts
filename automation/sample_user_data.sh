#!/bin/bash
# mariadb example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mariadb_103.sh | bash

# mariadb example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mariadb_104.sh | bash

# mariadb example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mariadb_105.sh | bash

# mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mysql_57.sh | bash

# mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mysql_80.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_80.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_8_0_19.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_8_0_23.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_8_0_25.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_8_0_28.sh | bash

# ps mysql example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PS_for_mysql_57.sh | bash

# PG example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PG_10.sh | bash

# PG example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PG_11.sh | bash

# PG example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PG_12.sh | bash

# PG example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PG_13.sh | bash

# PG example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_PG_14.sh | bash

# ansible example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.9.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.10.sh | bash

# ansible for ubuntu
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest_for_ubuntu.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.9_for_ubuntu.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_stable-2.10_for_ubuntu.sh | bash

# awscli example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_awscli.sh | bash

# awscli-v2 example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_awscli-v2.sh | bash

# terraform example
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_terraform.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_terraform.sh | bash -s -- "15"

# centos devops tools
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/centos_devops_install.sh | bash

# ubuntu devops tools
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/ubuntu_devops_install.sh | bash

# clickhouse install
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_clickhouse_mysql.sh | bash

# clickhouse mysql replication
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_clickhouse_mysql_replication.sh | bash

# install mysql 8.0.23 linux64 minimal
cd /usr/local/bin/
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/mysql-8.0.23-linux64-minimal.tgz -o mysql-8.0.23-linux64-minimal.tgz
tar -xzvf mysql-8.0.23-linux64-minimal.tgz
ln -r -s mysql-8.0.23-linux64-minimal/bin/mysql mysql
ln -r -s mysql-8.0.23-linux64-minimal/bin/mysqldump mysqldump
source /etc/profile

# install mysql 8.0.23 linux64 minimal
cd /usr/local/bin/
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/mysqlclient8.tgz -o mysqlclient8.tgz
tar -xzvf mysqlclient8.tgz
ln -r -s mysqlclient8/bin/mysql mysql
ln -r -s mysqlclient8/bin/mysqldump mysqldump
source /etc/profile

# password generalor linux/macos
curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/random_pwd.sh | bash

curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/random_pwd16.sh | bash

# tests curl + bash with parameters

curl http://foo.com/script.sh | bash -s arg1 arg2

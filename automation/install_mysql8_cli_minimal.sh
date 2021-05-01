#!/bin/bash
#### install mysql #####
verify_mysql=`mysql --version`
if [[ "${verify_mysql}" == "mysql"* ]] ; then
  echo "$verify_mysql is installed!"
  echo "MySQL-Path: $(which mysql)"
else
  # install mysql 8.0.23 linux64 minimal
  cd /usr/local/bin/
  curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/mysql-8.0.23-linux64-minimal.tgz -o mysql-8.0.23-linux64-minimal.tgz
  tar -xzvf mysql-8.0.23-linux64-minimal.tgz
  ln -r -s mysql-8.0.23-linux64-minimal/bin/mysql mysql
  ln -r -s mysql-8.0.23-linux64-minimal/bin/mysqldump mysqldump
  source /etc/profile
  mysql --version
  echo "MySQL-Path: $(which mysql)"
fi

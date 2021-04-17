#!/bin/bash
echo "HOSTNAME: " `hostname`
echo "BEGIN - [`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"
user=${1}
test_user=$(getent passwd $user)
echo $test_user
# configure user
if [ "$test_user" != "" ] ; then
        echo user $user exists
else
        echo user $user doesn\'t exists, creating $user right now!
        adduser $user
fi

# go to user directory
cd /home/$user

# configure variables
export SCRIPT_PATH=/home/$user
export DATA_DIR=$SCRIPT_PATH

# install oracle instant client 12c inux64 minimal
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/SOURCE/instantclient-basic-linux.x64-12.2.0.1.0.zip -o instantclient-basic-linux.x64-12.2.0.1.0.zip
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/SOURCE/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -o instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
curl -s https://raw.githubusercontent.com/emersongaudencio/linux_packages/master/SOURCE/instantclient-tools-linux.x64-12.2.0.1.0.zip -o instantclient-tools-linux.x64-12.2.0.1.0.zip

#wget https://github.com/emersongaudencio/linux_packages/raw/master/SOURCE/instantclient-basic-linux.x64-12.2.0.1.0.zip
#wget https://github.com/emersongaudencio/linux_packages/raw/master/SOURCE/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
#wget https://github.com/emersongaudencio/linux_packages/raw/master/SOURCE/instantclient-tools-linux.x64-12.2.0.1.0.zip

#### install unzip #####
verify_unzip=`rpm -qa | grep unzip`
if [[ "${verify_unzip}" == "unzip"* ]] ; then
   echo "$verify_unzip is installed!"
else
   yum install unzip -y
fi

# unzip downloaded files
unzip instantclient-basic-linux.x64-12.2.0.1.0.zip
unzip instantclient-sqlplus-linux.x64-12.2.0.1.0.zip
unzip instantclient-tools-linux.x64-12.2.0.1.0.zip
ln -s $SCRIPT_PATH/instantclient_12_2/libclntsh.so.12.1 $SCRIPT_PATH/instantclient_12_2/libclntsh.so

##### CONFIG .bashrc - Oracle #############
echo '# oracle-config' >> $SCRIPT_PATH/.bashrc
echo "export CLIENT_HOME=$SCRIPT_PATH/instantclient_12_2" >> $SCRIPT_PATH/.bashrc
echo 'export LD_LIBRARY_PATH=$CLIENT_HOME/' >> $SCRIPT_PATH/.bashrc
echo 'export PATH=$PATH:$CLIENT_HOME/' >> $SCRIPT_PATH/.bashrc
echo "export TNS_ADMIN=${DATA_DIR}" >> $SCRIPT_PATH/.bashrc
echo "export NLS_LANG=AMERICAN_AMERICA.AL32UTF8" >> $SCRIPT_PATH/.bashrc

#### tnsnames.ora sample #####
echo "rdsoracle =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = rdsoracle.test.api.cloud.blablabla.net)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = ORCL)
  )
)" > ${DATA_DIR}/tnsnames.ora

#!/bin/bash
echo "HOSTNAME: " `hostname`
echo "[`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"

### vars databases ###
# private ips
dbcluster01_ip="172.16.122.3"
dbcluster02_ip="172.16.122.4"
dbcluster03_ip="172.16.122.5"

# create ssh keys dir ##
mkdir -p /opt/keys/
cd /opt/keys/
ssh-keygen -q -f ansible -t rsa -b 4096 -q -P ""
ssh-copy-id -i ansible.pub $dbcluster01_ip
ssh-copy-id -i ansible.pub $dbcluster02_ip
ssh-copy-id -i ansible.pub $dbcluster03_ip

#### Percona XtraDB deployment ansible hosts variables ####
echo "[galeracluster]" > hosts
echo "dbcluster01 ansible_ssh_host=$dbcluster01_ip" >> hosts
echo "dbcluster02 ansible_ssh_host=$dbcluster02_ip" >> hosts
echo "dbcluster03 ansible_ssh_host=$dbcluster03_ip" >> hosts
### test ssh connection ###
ansible -m ping dbcluster01 -v -i hosts --private-key ansible
ansible -m ping dbcluster02 -v -i hosts --private-key ansible
ansible -m ping dbcluster03 -v -i hosts --private-key ansible

# Percona XtraDB Galera Cluster installation setup #
cd /opt
git clone https://github.com/emersongaudencio/ansible-percona-xtradb-cluster.git
cd ansible-percona-xtradb-cluster/ansible
priv_key="/opt/keys/ansible"
# adjusting ansible parameters
sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_xtradb_galera_install.sh
#### XtraDB deployment variables ####
GTID=$(($RANDOM))
echo $GTID > GTID
PXC_VERSION="80"
echo $PXC_VERSION > PXC_VERSION
CLUSTER_NAME="pxc80"
echo $CLUSTER_NAME > CLUSTER_NAME
#### Percona XtraDB deployment ansible hosts variables ####
echo "[galeracluster]" > hosts
echo "dbcluster01 ansible_ssh_host=$dbcluster01_ip" >> hosts
echo "dbcluster02 ansible_ssh_host=$dbcluster02_ip" >> hosts
echo "dbcluster03 ansible_ssh_host=$dbcluster03_ip" >> hosts
#### private key link ####
ln -s $priv_key ansible
#### Execution section ####
sudo sh run_xtradb_galera_install.sh dbcluster01 $PXC_VERSION $GTID "$dbcluster01_ip" "$CLUSTER_NAME" "$dbcluster01_ip,$dbcluster02_ip,$dbcluster03_ip"
sleep 30
sudo sh run_xtradb_galera_install.sh dbcluster02 $PXC_VERSION $GTID "$dbcluster01_ip" "$CLUSTER_NAME" "$dbcluster01_ip,$dbcluster02_ip,$dbcluster03_ip"
sleep 30
sudo sh run_xtradb_galera_install.sh dbcluster03 $PXC_VERSION $GTID "$dbcluster01_ip" "$CLUSTER_NAME" "$dbcluster01_ip,$dbcluster02_ip,$dbcluster03_ip"

#

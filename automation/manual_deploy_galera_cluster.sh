#!/bin/bash
echo "HOSTNAME: " `hostname`
echo "[`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"

### vars databases ###
# private ips
dbcluster01_ip="172.16.122.6"
dbcluster02_ip="172.16.122.7"
dbcluster03_ip="172.16.122.8"

# install sshpass
yum install sshpass -y

# create ssh keys dir ##
mkdir -p /opt/keys/
cd /opt/keys/
ssh-keygen -q -f ansible -t rsa -b 4096 -q -P "" &> /dev/null

sshpass -p${1} ssh-copy-id -i ansible.pub $dbcluster01_ip -o StrictHostKeyChecking=no
sshpass -p${1} ssh-copy-id -i ansible.pub $dbcluster02_ip -o StrictHostKeyChecking=no
sshpass -p${1} ssh-copy-id -i ansible.pub $dbcluster03_ip -o StrictHostKeyChecking=no

echo '# config file for ansible -- https://ansible.com/
# ===============================================

# nearly all parameters can be overridden in ansible-playbook
# or with command line flags. ansible will read ANSIBLE_CONFIG,
# ansible.cfg in the current working directory, .ansible.cfg in
# the home directory or /etc/ansible/ansible.cfg, whichever it
# finds first

[defaults]
inventory      = hosts

# performance parameters
internal_poll_interval = 0.001
forks = 20

# uncomment this to disable SSH key host checking
host_key_checking = False

# logging is off by default unless this path is defined
# if so defined, consider logrotate
log_path = ansible.log

# if set, always use this private key file for authentication, same as
# if passing --private-key to ansible or ansible-playbook
private_key_file = ansible

[privilege_escalation]
become=True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o PreferredAuthentications=publickey
pipelining = true
' > ansible.cfg

#### Percona XtraDB deployment ansible hosts variables ####
echo "[galeracluster]" > hosts
echo "dbcluster01 ansible_ssh_host=$dbcluster01_ip" >> hosts
echo "dbcluster02 ansible_ssh_host=$dbcluster02_ip" >> hosts
echo "dbcluster03 ansible_ssh_host=$dbcluster03_ip" >> hosts
### test ssh connection ###
ansible -m ping dbcluster01 -v
ansible -m ping dbcluster02 -v
ansible -m ping dbcluster03 -v

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

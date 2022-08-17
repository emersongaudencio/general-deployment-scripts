#!/bin/bash
echo "HOSTNAME: " `hostname`
echo "[`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"

### vars databases ###
# private ips
dbprimary01_ip="172.16.122.6"
dbreplica01_ip="172.16.122.7"
dbreplica02_ip="172.16.122.8"

### output directory ###
OUTPUT_DIR="output"
if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir -p ${OUTPUT_DIR}
    chmod 755 ${OUTPUT_DIR}
fi

# install sshpass
yum install sshpass -y

# create ssh keys dir ##
mkdir -p /opt/keys/
cd /opt/keys/
ssh-keygen -q -f ansible -t rsa -b 4096 -q -P "" &> /dev/null

sshpass -p${1} ssh-copy-id -i ansible.pub $dbprimary01_ip -o StrictHostKeyChecking=no
sshpass -p${1} ssh-copy-id -i ansible.pub $dbreplica01_ip -o StrictHostKeyChecking=no
sshpass -p${1} ssh-copy-id -i ansible.pub $dbreplica02_ip -o StrictHostKeyChecking=no

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

# create hosts file for ansible database replica setup #
echo "[dbservers]" > hosts
echo "dbprimary01 ansible_ssh_host=$dbprimary01_ip" >> hosts
echo "dbreplica01 ansible_ssh_host=$dbreplica01_ip" >> hosts
echo "dbreplica02 ansible_ssh_host=$dbreplica02_ip" >> hosts

### test ssh connection ###
ansible -m ping dbprimary01 -v
ansible -m ping dbreplica01 -v
ansible -m ping dbreplica02 -v

# create db_ips file for proxysql deployment #
echo "dbprimary01:$dbprimary01_ip" > db_ips.txt
echo "dbreplica01:$dbreplica01_ip" >> db_ips.txt
echo "dbreplica02:$dbreplica02_ip" >> db_ips.txt

# wait until ssh conn are fully deployed #
sleep 90

# setup change hostname #
ansible -i hosts -m shell -a "echo \"127.0.0.1 dbprimary01\" | sudo tee -a /etc/hosts && hostnamectl set-hostname dbprimary01" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_hostname_dbprimary01.txt
ansible -i hosts -m shell -a "echo \"127.0.0.1 dbreplica01\" | sudo tee -a /etc/hosts && hostnamectl set-hostname dbreplica01" dbreplica01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_hostname_dbreplica01.txt
ansible -i hosts -m shell -a "echo \"127.0.0.1 dbreplica02\" | sudo tee -a /etc/hosts && hostnamectl set-hostname dbreplica02" dbreplica02 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_hostname_dbreplica02.txt

# deploy MariaDB to the new VM instances using Ansible
ansible -i hosts -m shell -a "curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mariadb_104.sh | sudo bash" dbservers -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/install_mariadb_dbservers.txt

# wait until databases are fully deployed #
sleep 60

# replication setup using ansbile for automation purpose #
ansible -i hosts -m shell -a "mysql -N -e 'show master status'" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_master_position.txt
ansible -i hosts -m shell -a "cat /root/.my.cnf | grep replication_user" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_user_master.txt
# get replication_credentials info
rep_user=$(cat ${OUTPUT_DIR}/setup_replication_user_master.txt | awk -F "|" {'print $4'} | awk {'print $3'})
rep_pwd=$(cat ${OUTPUT_DIR}/setup_replication_user_master.txt | awk -F "|" {'print $4'} | awk {'print $6'})
# get replication file info #
log_file=$(cat ${OUTPUT_DIR}/setup_replication_master_position.txt | awk -F "|" {'print $4'} | awk {'print $2'})
log_position=$(cat ${OUTPUT_DIR}/setup_replication_master_position.txt | awk -F "|" {'print $4'} | awk {'print $3'})
# get replication gtid position info #
ansible -i hosts -m shell -a 'mysql -N -e "SELECT BINLOG_GTID_POS(\"{{ log_file }}\",\"{{ log_position }}\");"' dbprimary01 -u $ansible_user --private-key=$priv_key --become -e "{log_file: '$log_file', log_position: '$log_position'}" -o > ${OUTPUT_DIR}/setup_replication_master_gtid.txt
gtid_slave_pos=$(cat ${OUTPUT_DIR}/setup_replication_master_gtid.txt | awk -F "|" {'print $4'} | awk {'print $2'})
# setup replica read_only = ON #
ansible -i hosts -m shell -a "mysql -N -e 'set global read_only = 1; select @@read_only;'; echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf && echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf && echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf && echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf && echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf && echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf && echo 'slave_parallel_mode = \"optimistic\"' >> /etc/my.cnf.d/server_replica.cnf;" dbreplica01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_dbreplica01_read_only.txt
ansible -i hosts -m shell -a "mysql -N -e 'set global read_only = 1; select @@read_only;'; echo '[mariadb]' > /etc/my.cnf.d/server_replica.cnf && echo 'read_only = 1' >> /etc/my.cnf.d/server_replica.cnf && echo 'innodb_flush_log_at_trx_commit = 2' >> /etc/my.cnf.d/server_replica.cnf && echo 'log_slave_updates = 0' >> /etc/my.cnf.d/server_replica.cnf && echo 'slave_parallel_threads = 8' >> /etc/my.cnf.d/server_replica.cnf && echo 'slave_parallel_max_queued = 536870912' >> /etc/my.cnf.d/server_replica.cnf && echo 'slave_parallel_mode = \"optimistic\"' >> /etc/my.cnf.d/server_replica.cnf;" dbreplica02 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_dbreplica02_read_only.txt
# setup replication on replica servers #
master_host=$(cat ${OUTPUT_DIR}/db_ips.txt | grep dbprimary01 | awk -F ":" {'print $2'})
ansible -i hosts -m shell -a 'mysql -N -e "SET GLOBAL gtid_slave_pos = \"{{ gtid_slave_pos }}\"; CHANGE MASTER TO master_host=\"{{ master_host }}\", master_port=3306, master_user=\"{{ master_user }}\", master_password = \"{{ master_password }}\", master_use_gtid=slave_pos; START SLAVE; SHOW SLAVE STATUS\G"' dbreplica01 -u $ansible_user --private-key=/root/repos/ansible_keys/ansible --become -e "{gtid_slave_pos: '$gtid_slave_pos', master_host: '$master_host', master_user: '$rep_user' , master_password: '$rep_pwd' }" -o > ${OUTPUT_DIR}/setup_replication_dbreplica01_activation.txt
ansible -i hosts -m shell -a 'mysql -N -e "SET GLOBAL gtid_slave_pos = \"{{ gtid_slave_pos }}\"; CHANGE MASTER TO master_host=\"{{ master_host }}\", master_port=3306, master_user=\"{{ master_user }}\", master_password = \"{{ master_password }}\", master_use_gtid=slave_pos; START SLAVE; SHOW SLAVE STATUS\G"' dbreplica02 -u $ansible_user --private-key=/root/repos/ansible_keys/ansible --become -e "{gtid_slave_pos: '$gtid_slave_pos', master_host: '$master_host', master_user: '$rep_user' , master_password: '$rep_pwd' }" -o > ${OUTPUT_DIR}/setup_replication_dbreplica02_activation.txt
# setup proxysql user for monitoring purpose #
# ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "mysql -N -e \"GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'proxysqlchk'@'%' IDENTIFIED BY 'Test123?dba';\"" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_proxysql_user.txt
# restart replicas #
ansible -i hosts -m shell -a "sudo service mariadb restart" dbreplica01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_dbreplica01_restart.txt
ansible -i hosts -m shell -a "sudo service mariadb restart" dbreplica02 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_dbreplica02_restart.txt

echo "Database deployment has been completed successfully!"

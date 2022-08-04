#!/bin/bash
#### install lvm2 #####
verify_lvm=`rpm -qa | grep lvm`
if [[ "${verify_lvm}" == "lvm"* ]] ; then
  echo "$verify_lvm is installed!"
else
  sudo yum install lvm2 -y
fi

# volume setup
vgchange -ay

### configuring MySQL data disks

list_data_disk=$(fdisk -l | sed 's/\/dev\/nvme0n1//' | grep "20 GiB" | awk '{print $2}' | sed 's/://' | awk 'FNR < 3')
check_num_of_data_disk=$(echo $list_data_disk | wc -w)

if [ ${check_num_of_data_disk} -eq 1 ]; then
  pvcreate $list_data_disk
  vgcreate VGMySQLData $list_data_disk
  lvcreate -n LVMySQLData -l 100%FREE VGMySQLData
  sleep 5
  mkfs.xfs -K /dev/VGMySQLData/LVMySQLData
  sleep 5
  mkdir -p /mysql/datadir
  echo '/dev/VGMySQLData/LVMySQLData /mysql/datadir xfs defaults,noatime,nodiratime 0 0' >> /etc/fstab
  mount /mysql/datadir
else
  echo "Please check if the number of disks available is equal 1!"
fi

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

DEVICE="/dev/sdb"
DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`
LVM_FLAG=1
if [ "`echo -n $DEVICE_FS`" == "" ] ; then
  # wait for the device to be attached
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
    if [[ $DEVICEEXISTS != "1" ]]; then
      sleep 3
      # flag to not create lvm
      LVM_FLAG=0
    fi
  done

  if [[ $LVM_FLAG == "0" ]]; then
    DEVICE="/dev/nvme1n1"
    LVM_FLAG=1
    # wait for the device to be attached
    DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
    DEVICEEXISTS=''
    while [[ -z $DEVICEEXISTS ]]; do
      echo "checking $DEVICENAME"
      DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
      if [[ $DEVICEEXISTS != "1" ]]; then
        sleep 3
        # flag to not create lvm
        LVM_FLAG=0
      fi
    done
  fi

  if [[ $LVM_FLAG == "1" ]]; then
    pvcreate ${DEVICE}
    vgcreate data ${DEVICE}
    lvcreate --name volume1 -l 100%FREE data
    sleep 5
    mkfs.xfs /dev/data/volume1
    sleep 5
    mkdir -p /var/lib/docker
    echo '/dev/data/volume1 /var/lib/docker xfs defaults 0 0' >> /etc/fstab
    mount /var/lib/docker
  fi

fi

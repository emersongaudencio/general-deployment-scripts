#!/bin/bash
# os_type = rhel
os_type=
# os_version as demanded by the OS (codename, major release, etc.)
os_version=
supported="Only RHEL/CentOS 7 & 8 are supported for this installation process."

msg(){
    type=$1 #${1^^}
    shift
    printf "[$type] %s\n" "$@" >&2
}

error(){
    msg error "$@"
    exit 1
}

identify_os(){
    arch=$(uname -m)
    # Check for RHEL/CentOS, Fedora, etc.
    if command -v rpm >/dev/null && [[ -e /etc/redhat-release || -e /etc/os-release ]]
    then
        os_type=rhel
        el_version=$(rpm -qa '(oraclelinux|sl|redhat|centos|fedora|rocky|alma|system)*release(|-server)' --queryformat '%{VERSION}')
        case $el_version in
            1*) os_version=6 ; error "RHEL/CentOS 6 is no longer supported" "$supported" ;;
            2*) os_version=7 ;;
            5*) os_version=5 ; error "RHEL/CentOS 5 is no longer supported" "$supported" ;;
            6*) os_version=6 ; error "RHEL/CentOS 6 is no longer supported" "$supported" ;;
            7*) os_version=7 ;;
            8*) os_version=8 ;;
             *) error "Detected RHEL or compatible but version ($el_version) is not supported." "$supported"  "$otherplatforms" ;;
         esac
         if [[ $arch == aarch64 ]] && [[ $os_version != 7 ]]; then error "Only RHEL/CentOS 7 are supported for ARM64. Detected version: '$os_version'"; fi
    fi

    if ! [[ $os_type ]] || ! [[ $os_version ]]
    then
        error "Could not identify OS type or version." "$supported"
    fi
}

### OS auto discovey to identify which is the OS and version thats been used it.
identify_os

echo $os_type
echo $os_version

####### PACKAGES ###########################
if [[ $os_type == "rhel" ]]; then
    if [[ $os_version == "7" ]]; then
      # -------------- For RHEL/CentOS 7 --------------
      $(type -p dnf || type -p yum) -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    elif [[ $os_version == "8" ]]; then
      # -------------- For RHEL/CentOS 8 --------------
      $(type -p dnf || type -p yum) -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

    fi
fi

verify_keydb=`rpm -qa | grep keydb`
if [[ $verify_keydb == "keydb"* ]]
then
echo "$verify_keydb is installed!"
else
   ##### FIREWALLD DISABLE #########################
   systemctl disable firewalld
   systemctl stop firewalld
   ######### SELINUX ###############################
   sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
   # disable selinux on the fly
   /usr/sbin/setenforce 0
   # disable transparent huge pages
   echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.d/rc.local
   echo "echo never > /sys/kernel/mm/transparent_hugepage/defrag" >> /etc/rc.d/rc.local
   chmod +x /etc/rc.d/rc.local

   if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
     echo never > /sys/kernel/mm/transparent_hugepage/enabled
   fi
   if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
     echo never > /sys/kernel/mm/transparent_hugepage/defrag
   fi

   ### install pre-packages ####
   $(type -p dnf || type -p yum) -y install screen nload bmon openssl libaio rsync snappy net-tools wget nmap htop dstat sysstat curl gnupg2

   ### Installation Redis via yum/dnf ###
   if [[ $os_version == "7" ]]; then
     # -------------- For RHEL/CentOS 7 --------------
     $(type -p dnf || type -p yum) -y install https://download.keydb.dev/pkg/open_source/rpm/centos7/x86_64/keydb-latest-1.el7.x86_64.rpm
   elif [[ $os_version == "8" ]]; then
     # -------------- For RHEL/CentOS 8 --------------
     $(type -p dnf || type -p yum) -y install https://download.keydb.dev/pkg/open_source/rpm/centos8/x86_64/keydb-latest-1.el8.x86_64.rpm
   fi

   ##### CONFIG PROFILE #############
   check_profile=$(cat /etc/profile | grep '# keydb-pre-reqs' | wc -l)
   if [ "$check_profile" == "0" ]; then
   echo ' ' >> /etc/profile
   echo '# keydb-pre-reqs' >> /etc/profile
   echo 'if [ $USER = "keydb" ]; then' >> /etc/profile
   echo '  if [ $SHELL = "/bin/bash" ]; then' >> /etc/profile
   echo '    ulimit -u 65536 -n 65536' >> /etc/profile
   echo '  else' >> /etc/profile
   echo '    ulimit -u 65536 -n 65536' >> /etc/profile
   echo '  fi' >> /etc/profile
   echo 'fi' >> /etc/profile
   else
   echo "keydb Pre-reqs for /etc/profile is already in place!"
   fi

   #####  Redis LIMITS ###########################
   check_limits=$(cat /etc/security/limits.conf | grep '# keydb-pre-reqs' | wc -l)
   if [ "$check_limits" == "0" ]; then
   echo ' ' >> /etc/security/limits.conf
   echo '# keydb-pre-reqs' >> /etc/security/limits.conf
   echo 'keydb              soft    nproc   102400' >> /etc/security/limits.conf
   echo 'keydb              hard    nproc   102400' >> /etc/security/limits.conf
   echo 'keydb              soft    nofile  102400' >> /etc/security/limits.conf
   echo 'keydb              hard    nofile  102400' >> /etc/security/limits.conf
   echo 'keydb              soft    stack   102400' >> /etc/security/limits.conf
   echo 'keydb              soft    core unlimited' >> /etc/security/limits.conf
   echo 'keydb              hard    core unlimited' >> /etc/security/limits.conf
   echo '# all_users' >> /etc/security/limits.conf
   echo '* soft nofile 102400' >> /etc/security/limits.conf
   echo '* hard nofile 102400' >> /etc/security/limits.conf
   else
   echo "keydb Pre-reqs for /etc/security/limits.conf is already in place!"
   fi

   ##### Redis SYSCTL ###########################
   check_sysctl=$(cat /etc/sysctl.conf | grep '# keydb-pre-reqs' | wc -l)
   if [ "$check_sysctl" == "0" ]; then
   # insert parameters into /etc/sysctl.conf for incresing Redis limits
   echo "# keydb-pre-reqs
# virtual memory limits
vm.swappiness = 1
vm.dirty_background_ratio = 3
vm.dirty_ratio = 40
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
fs.suid_dumpable = 1
vm.nr_hugepages = 0
vm.overcommit_memory = 1
# file system limits
fs.aio-max-nr = 1048576
fs.file-max = 6815744
# kernel limits
kernel.panic_on_oops = 1
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.shmmni = 4096
# kernel semaphores: semmsl, semmns, semopm, semmni
kernel.sem = 250 32000 100 128
# networking limits
net.ipv4.ip_local_port_range = 9000 65499
net.core.somaxconn=1024
net.core.rmem_default=4194304
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048586" >> /etc/sysctl.conf
   else
   echo "keydb Pre-reqs for /etc/sysctl.conf is already in place!"
   fi
   # reload confs of /etc/sysctl.confs
   sysctl -p

   #####  Redis LIMITS ###########################
   mkdir -p /etc/systemd/system/keydb.service.d/
   echo '[Service]' > /etc/systemd/system/keydb.service.d/limit.conf
   echo 'LimitNOFILE=102400' >> /etc/systemd/system/keydb.service.d/limit.conf
   systemctl daemon-reload
fi

# basic config settings /etc/redis.conf
#bind * -::*
#requirepass  <AuthPassword>
#appendonly yes
#appendfilename "appendonly.aof"

# service commands
#systemctl enable --now keydb
#systemctl restart keydb
#systemctl status keydb

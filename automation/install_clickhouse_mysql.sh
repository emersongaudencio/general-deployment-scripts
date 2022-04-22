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
# yum -y install epel-release
fi

verify_clickhouse=`rpm -qa | grep clickhouse`
if [[ $verify_clickhouse == "clickhouse"* ]]
then
echo "$verify_clickhouse is installed!"
else
   ##### FIREWALLD DISABLE #########################
   systemctl disable firewalld
   systemctl stop firewalld
   ######### SELINUX ###############################
   sed -ie 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
   # disable selinux on the fly
   /usr/sbin/setenforce 0

   ### install pre-packages ####
   $(type -p dnf || type -p yum) -y install screen nload bmon openssl libaio rsync snappy net-tools wget nmap htop dstat sysstat

   ### Installation MARIADB via yum ####
   curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash
   $(type -p dnf || type -p yum) -y install MariaDB-client

   ### Installation Clickhouse via yum ###
   $(type -p dnf || type -p yum) -y install curl gnupg2
   curl https://builds.altinity.cloud/yum-repo/altinity.repo -o /etc/yum.repos.d/altinity.repo

   version=21.8.13.1.altinitystable
   $(type -p dnf || type -p yum) -y install clickhouse-common-static-$version clickhouse-server-$version clickhouse-client-$version

   ##### CONFIG PROFILE #############
   check_profile=$(cat /etc/profile | grep '# clickhouse-pre-reqs' | wc -l)
   if [ "$check_profile" == "0" ]; then
   echo ' ' >> /etc/profile
   echo '# clickhouse-pre-reqs' >> /etc/profile
   echo 'if [ $USER = "clickhouse" ]; then' >> /etc/profile
   echo '  if [ $SHELL = "/bin/bash" ]; then' >> /etc/profile
   echo '    ulimit -u 65536 -n 65536' >> /etc/profile
   echo '  else' >> /etc/profile
   echo '    ulimit -u 65536 -n 65536' >> /etc/profile
   echo '  fi' >> /etc/profile
   echo 'fi' >> /etc/profile
   else
   echo "Clickhouse Pre-reqs for /etc/profile is already in place!"
   fi

   #####  ProxySQL LIMITS ###########################
   check_limits=$(cat /etc/security/limits.conf | grep '# clickhouse-pre-reqs' | wc -l)
   if [ "$check_limits" == "0" ]; then
   echo ' ' >> /etc/security/limits.conf
   echo '# clickhouse-pre-reqs' >> /etc/security/limits.conf
   echo 'clickhouse              soft    nproc   102400' >> /etc/security/limits.conf
   echo 'clickhouse              hard    nproc   102400' >> /etc/security/limits.conf
   echo 'clickhouse              soft    nofile  102400' >> /etc/security/limits.conf
   echo 'clickhouse              hard    nofile  102400' >> /etc/security/limits.conf
   echo 'clickhouse              soft    stack   102400' >> /etc/security/limits.conf
   echo 'clickhouse              soft    core unlimited' >> /etc/security/limits.conf
   echo 'clickhouse              hard    core unlimited' >> /etc/security/limits.conf
   echo '# all_users' >> /etc/security/limits.conf
   echo '* soft nofile 102400' >> /etc/security/limits.conf
   echo '* hard nofile 102400' >> /etc/security/limits.conf
   else
   echo "Clickhouse Pre-reqs for /etc/security/limits.conf is already in place!"
   fi

fi

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
      yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    elif [[ $os_version == "8" ]]; then
      # -------------- For RHEL/CentOS 8 --------------
      yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    fi
# yum -y install epel-release
fi

#### install python3 #####
verify_python=`rpm -qa | grep python3-3`
if [[ "${verify_python}" == "python3-3"* ]] ; then
   echo "$verify_python is installed!"
else
   yum -y install python3
   yum -y install python3-mysqlclient
fi

#### install pip #####
verify_pip=`pip -V`
if [[ "${verify_pip}" == "pip"* ]] ; then
   echo "$verify_pip is installed!"
   echo "Pip-Path: $(which pip)"
else
   curl -sS https://bootstrap.pypa.io/get-pip.py | python3
   source ~/.bashrc
   pip -V
   echo "Pip-Path: $(which pip)"
fi

#### install clickhouse-mysql #####
verify_clickhouse_mysql=`clickhouse-mysql -h`
if [[ "${verify_clickhouse_mysql}" == "clickhouse-mysql"* ]] ; then
  echo "$verify_clickhouse_mysql is installed!"
  echo "Clickhouse-mysql-Path: $(which clickhouse-mysql)"
else
  python3 -m pip --no-cache-dir install clickhouse-mysql
  source ~/.bashrc
  clickhouse-mysql -h
  echo "Clickhouse-mysql-Path: $(which clickhouse-mysql)"
fi

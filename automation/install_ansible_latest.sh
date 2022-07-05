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

#### install python3 #####
verify_python=$(/usr/local/bin/python3.9 --version)
if [[ "${verify_python}" == "Python3"* ]] ; then
   echo "$verify_python is installed!"
else
   ####### PACKAGES ###########################
   if [[ $os_type == "rhel" ]]; then
       if [[ $os_version == "7" ]]; then
         # -------------- For RHEL/CentOS 7 --------------
         #### install python3 #####
         cd /opt
         $(type -p dnf || type -p yum) install wget gcc openssl-devel libffi-devel bzip2-devel -y
         wget https://www.python.org/ftp/python/3.9.13/Python-3.9.13.tgz
         tar xzvf ./Python-3.9.13.tgz
         cd ./Python-3.9.13
         ./configure --enable-optimizations
         make altinstall

         $(type -p python3.9 || type -p python3) --version
         $(type -p pip3.9 || type -p pip3) --version
         $(type -p python3.9 || type -p python3) -m pip install --upgrade pip
       elif [[ $os_version == "8" ]]; then
         # -------------- For RHEL/CentOS 8 --------------
         $(type -p dnf || type -p yum) install python39 -y
         $(type -p python3.9 || type -p python3) --version
         $(type -p pip3.9 || type -p pip3) --version
         $(type -p python3.9 || type -p python3) -m pip install --upgrade pip
       fi
   fi
fi

#### install git #####
verify_git=$(git --help)
if [[ "${verify_git}" == "git"* ]] ; then
   echo "$verify_git is installed!"
else
   $(type -p dnf || type -p yum) install git -y
fi

#### install ansible #####
verify_ansible=$(ansible --version)
if [[ "${verify_ansible}" == "ansible"* ]] ; then
  echo "$verify_ansible is installed!"
  echo "Ansible-Path: $(which ansible)"
else
  ####### PACKAGES ###########################
  if [[ $os_type == "rhel" ]]; then
    $(type -p python3.9 || type -p python3) -m pip install ansible
    source ~/.bashrc
    $(which ansible) --version
    echo "Ansible-Path: $(which ansible)"
  fi
fi

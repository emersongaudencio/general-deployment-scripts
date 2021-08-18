#!/bin/bash
#### install terraform #####
terraform_version=${1}

verify_terraform=`terraform -v`
if [[ "${verify_terraform}" == "Terraform"* ]] ; then
  echo "$verify_terraform has been installed already!"
  echo "Terraform-Path: $(which terraform)"
else
  ### terraform download ###
  if [[ -d "/opt/terraform" ]] ; then
    echo "Directory /opt/terraform exists."
  else
    cd /opt/
    mkdir -p terraform
  fi
  if [[ "${terraform_version}" == "12" ]] ; then
    cd /opt/terraform
    yum install wget unzip -y
    wget https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip
    unzip ./terraform_0.12.30_linux_amd64.zip
    mv terraform /usr/local/bin/
    source ~/.bashrc
    terraform -v
    echo "Terraform-Path: $(which terraform)"
  elif [[ "${terraform_version}" == "13" ]] ; then
    cd /opt/terraform
    yum install wget unzip -y
    wget https://releases.hashicorp.com/terraform/0.13.7/terraform_0.13.7_linux_amd64.zip
    unzip ./terraform_0.13.6_linux_amd64.zip
    mv terraform /usr/local/bin/
    source ~/.bashrc
    terraform -v
    echo "Terraform-Path: $(which terraform)"
  elif [[ "${terraform_version}" == "14" ]] ; then
    cd /opt/terraform
    yum install wget unzip -y
    wget https://releases.hashicorp.com/terraform/0.14.11/terraform_0.14.11_linux_amd64.zip
    unzip ./terraform_0.14.10_linux_amd64.zip
    mv terraform /usr/local/bin/
    source ~/.bashrc
    terraform -v
    echo "Terraform-Path: $(which terraform)"
  elif [[ "${terraform_version}" == "15" ]] ; then
    cd /opt/terraform
    yum install wget unzip -y
    wget https://releases.hashicorp.com/terraform/0.15.5/terraform_0.15.5_linux_amd64.zip
    unzip ./terraform_0.15.5_linux_amd64.zip
    mv terraform /usr/local/bin/
    source ~/.bashrc
    terraform -v
    echo "Terraform-Path: $(which terraform)"
  else
    cd /opt/terraform
    yum install wget unzip -y
    wget https://releases.hashicorp.com/terraform/1.0.4/terraform_1.0.4_linux_amd64.zip
    unzip ./terraform_1.0.4_linux_amd64.zip
    mv terraform /usr/local/bin/
    source ~/.bashrc
    terraform -v
    echo "Terraform-Path: $(which terraform)"
  fi
fi

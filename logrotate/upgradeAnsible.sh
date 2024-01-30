#!/bin/bash

if [[ `id -u` -ne 0 ]] ; then echo "Please login as root user"; exit 1; fi

# Getting current version of ansible
cv=`ansible --version | head -1 | awk '{print substr($NF, 1, length($1)-1)}'`

echo "Upgrading Ansible from $cv to latest version ..."
echo "Step1: Removing current version"
apt remove ansible -y

echo "Step2: Removing all files related to ansible"
apt --purge autoremove -y

echo "Step3: Install common libraries"
apt install software-properties-common -y

echo "Step4: Install repo"
apt-add-repository ppa:ansible/ansible -y

echo "Step 5: Update the packages ..."
apt update

echo "Step 6: Install latest version of Ansible ..."
apt install ansible -y

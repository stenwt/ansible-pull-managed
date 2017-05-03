#!/bin/bash

# Don't do this:
# curl https://raw.githubusercontent.com/stenwt/ansible-pull-managed/master/bootstrap.sh | sudo NAME=my.fq.dn bash
 
# Get Ansible installed so we can that it can manage this host

# Get OS + version so we know how to install Ansible + deps
function whathosttypeami { 
  ostype=""
  osvers=""
  if [ -f /etc/fedora-release ]; then 
    ostype="fedora"
    osvers=$(rpm -q --qf "%{VERSION}" fedora-release)
  fi
  if [ -f /etc/centos-release ]; then    
    ostype="centos"
    osvers=$(rpm -q --qf "%{VERSION}" centos-release)
  fi 
  if [ -f /etc/redhat-release -a ! -f /etc/fedora-release ]; then
    ostype="rhel"
    osvers=$(rpm -q --qf "%{VERSION}" redhat-release)
  fi
  ## debian, rasbian, what else? 
  export ostype osvers
} 

whathosttypeami

# Install Ansible using system package manager, with whatever deps we'll need right away
function installansiblewithdeps { 
  case $ostype in
  fedora)
    if [ $osvers -ge 22 ]; then
      ## whoever decided to rename yum to dnf can go dnf themselves
      dnf -y install git ansible python-dnf libselinux-python
    else
      yum -y install git ansible python-yum
    fi 
    ;;
  centos|rhel)
    yum -y install git ansible 
    ;;
  *)
    echo "this host type is not added yet"
   ;;
  esac
}

installansiblewithdeps

# Grab my ansible-pull repo and set up config management
if [ $(git --version) -a $(ansible --version) ]; then
  pushd $(mktemp)
  git clone https://github.com/stenwt/ansible-pull-managed
  cd ansible-pull-managed
  ansible-playbook manage-me.yml -e fqdn=$NAME
else
  echo "Something failed, not going further"
fi

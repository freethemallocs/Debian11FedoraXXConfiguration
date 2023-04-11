#!/bin/bash

source "${0%/*}/library.packages.sh"

umask 077

set -e
set -f
set -u

################################################################################
# Verify we are running as a non root user with sudo privileges
################################################################################
strRegex=' ?sudo ?'
strUser="root"
if [[ "$(groups)" =~ $strRegex ]] ; then
  strUser="$(whoami)"
fi
if [ "root" = "${strUser}" ]; then
  echo "[ERROR] Current user must be an administrator that has sudo privileges"
  exit 8
fi

################################################################################
# Install Secure Shell
################################################################################
functionUpgrade
installPackageViaRepository openssh-server

################################################################################
# Change 
# PermitRootLogin without-password
# To
# PermitRootLogin yes
################################################################################
sudo sed -i "s/#PermitRootLogin .*/PermitRootLogin yes/g" /etc/ssh/sshd_config


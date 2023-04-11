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
# Install frequently used tools
################################################################################
functionUpgrade
installPackageViaRepository nano 
installPackageViaRepository net-tools 
installPackageViaRepository gnupg 
installPackageViaRepository wget 
installPackageViaRepository jsvc 
installPackageViaRepository curl 
installPackageViaRepository apt-transport-https


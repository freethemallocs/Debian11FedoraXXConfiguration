#!/bin/bash

source "${0%/*}/library.packages.sh"

umask 077

set -e
set -f
set -u

################################################################################
# https://www.ui.com/download/unifi/default/default/unifi-network-application-7166-debianubuntu-linux-and-unifi-cloud-key
################################################################################

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
installPackageViaRepository binutils
installPackageViaRepository curl
installPackageViaRepository openjdk-11-jre-headless


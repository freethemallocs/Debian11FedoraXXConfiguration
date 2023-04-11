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
# Update machine and install tools needed for virtual box guest tools
################################################################################
functionUpgrade
installPackageViaRepository "build-essential"
installPackageViaRepository "dkms"
installPackageViaRepository linux-headers-$(uname -r)

################################################################################
# Restart machine to apply changes
################################################################################
sudo /sbin/shutdown -h 60
echo "A shutdown of the system is needed to apply changes and remove any connected CD ROMs"
read -p "Shutdown system (Y/N)? " strResult
if [[ "${strResult}" =~ ^[Nn].*$ ]]; then
  sudo /sbin/shutdown -c
  echo "System not shut down"
  echo "Please restart system later and remove any connected CD ROMs"
else
  sudo /sbin/shutdown -h now
fi

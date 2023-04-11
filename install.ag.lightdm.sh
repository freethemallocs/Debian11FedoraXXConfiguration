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
# Check to see if lightdm is installed
################################################################################
if (isPackageInstalled "lightdm"); then
  echo "[NOTE] lightdm is installed"
else
  echo "[ERROR] lightdm does not appear to be installed"
  read -p "Abort operation (Y/N)? " strResult
  if [[ "${strResult}" =~ ^[Yy].*$ ]]; then
    echo "[NOTE] lightdm not configured"
    exit 8
  fi
fi

################################################################################
# Only do this if using GUI / lightdm
################################################################################
sudo sed -i "s/#greeter-hide-users=false/greeter-hide-users=false/g" /etc/lightdm/lightdm.conf

################################################################################
# Restart machine to apply changes
################################################################################
sudo /sbin/shutdown -r 60
echo "A restart of the system is needed to apply changes"
read -p "Restart system (Y/N)? " strResult
if [[ "${strResult}" =~ ^[Nn].*$ ]]; then
  sudo /sbin/shutdown -c
  echo "System not restarted"
  echo "Please restart system later"
else
  sudo /sbin/shutdown -r now
fi


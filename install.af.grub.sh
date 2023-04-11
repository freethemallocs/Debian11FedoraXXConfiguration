#!/bin/bash

source "${0%/*}/library.packages.sh"

umask 077

set -e
set -f
set -u

function isGrubBootLoaderInstalled
{
     if (isPackageInstalled "grub-pc"); then
          return 0
     fi
     
     if (isPackageInstalled "grub-efi-amd64"); then
          return 0
     fi

     return 1
}

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
# Check to see if grub is installed
################################################################################
if ! (isGrubBootLoaderInstalled); then
  echo "[ERROR] Grub bootloader does not appear to be installed"
  read -p "Abort operation (Y/N)? " strResult
  if [[ "${strResult}" =~ ^[Yy].*$ ]]; then
    echo "[NOTE] Grub bootloader not configured"
    exit 8
  fi
fi
echo "[NOTE] Grub bootloader is installed"

################################################################################
# Configure grub bootloader to have a timeout of zero
################################################################################
sudo sed -i "s/GRUB_TIMEOUT=[0-9]/GRUB_TIMEOUT=0/g" /etc/default/grub
sudo /usr/sbin/update-grub
# sudo /usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg

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


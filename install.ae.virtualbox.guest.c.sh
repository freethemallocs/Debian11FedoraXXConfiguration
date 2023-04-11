#!/bin/bash

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
# Add user to group vboxsf
################################################################################
echo "sudo /usr/sbin/usermod -aG vboxsf \"${strUser}\""
sudo /usr/sbin/usermod -aG vboxsf "${strUser}"

################################################################################
# Verify we added user correctly to group of vboxsf
# Restart machine to apply changes
################################################################################
set +e
strUsermodTestResult=$(cat /etc/group | grep -io "^vboxsf.*[,:]\?${strUser}[,]\?" | grep -io "[,:]\?${strUser}[,]\?"  | grep -io "${strUser}")
set -e
if [ "${strUsermodTestResult}" = "${strUser}" ]; then
     echo "Added ${strUser} to vboxsf group"
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
else
  echo "ERROR: Failed to add ${strUser} to vboxsf group"
fi


























################################################################################
# Restart machine to apply changes
################################################################################
echo "A restart of the system is needed"
sudo /sbin/shutdown -h 60
read -p "Press any key to shutdown the system and remove any connected CD ROMs..."
sudo /sbin/shutdown now


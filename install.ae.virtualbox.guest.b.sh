#!/bin/bash

umask 077

set -e
set -f
set -u

################################################################################
# The following commands might have to be manually run
# ls -al /dev/cdrom*
# sudo mount /dev/sr0 /media/cdrom0
# sudo sh ./VBoxLinuxAdditions.run --nox11
# sudo /sbin/shutdown -h now
# Remove guest additions CD ROM when done
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
# Set configuration variables
################################################################################
strFilePathDev="/dev/cdrom"
strFolderPathMountRoot="/media"
strFolderPathMountCDROM="${strFolderPathMountRoot}/cdrom"

################################################################################
# Check file structure of device being mounted
################################################################################
if [ -h "${strFilePathDev}" ]; then
     echo "[NOTE] File system object is a soft link ${strFilePathDev}"
     strFilePathDev=$(/usr/bin/readlink -f "${strFilePathDev}")
     echo "[NOTE] File system object changed to ${strFilePathDev}"
elif [ -b "${strFilePathDev}" ]; then
     echo "[NOTE] File system object is a block special file ${strFilePathDev}"
elif [ -f "${strFilePathDev}" ]; then
     echo "[NOTE] File system object is a regular file ${strFilePathDev}"
fi
if [ ! -b "${strFilePathDev}" ]; then
     echo "[ERROR] Failed to locate file ${strFilePathDev}"
     exit 
fi 

################################################################################
# Check file structure of target mount folder
################################################################################
if [ -h "${strFolderPathMountCDROM}" ]; then
     echo "[NOTE] File system object is a soft link ${strFolderPathMountCDROM}"
     strFolderPathMountCDROM=$(/usr/bin/readlink -f "${strFolderPathMountCDROM}")
     echo "[NOTE] File system object changed to ${strFolderPathMountCDROM}"
elif [ -d "${strFolderPathMountCDROM}" ]; then
     echo "[NOTE] File system object is a directory ${strFolderPathMountCDROM}"
fi

################################################################################
# Create mount folder structure
############################################################################
if [ ! -d "${strFolderPathMountCDROM}" ]; then
     sudo mkdir -pv "${strFolderPathMountCDROM}"
     sudo chmod -vR go-wx "${strFolderPathMountCDROM}"
     sudo chmod -vR go+r "${strFolderPathMountCDROM}"
     sudo chown -vR "root:root" "${strFolderPathMountCDROM}"
fi 
if [ ! -d "${strFolderPathMountCDROM}" ]; then
     echo "[ERROR] Failed to locate folder ${strFolderPathMountRoot}"
     exit 8
fi

################################################################################
# Mount CDROM
#############################################################################
sudo mount "${strFilePathDev}" "${strFolderPathMountCDROM}"

################################################################################
# Install Virual Box Guest Additions
#############################################################################
sudo /bin/bash "${strFolderPathMountCDROM}/VBoxLinuxAdditions.run" "--nox11"

################################################################################
# Cleanup
#############################################################################
sudo umount /dev/sr0

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



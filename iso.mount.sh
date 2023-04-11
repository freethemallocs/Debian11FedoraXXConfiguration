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


#!/bin/bash

umask 077

set -e
set -f
set -u

function backupFile
{
  local strUser="$1"
  local strPathOfFolderToPlaceBackupIn="$2"
  local strPathOfFileToBackup="$3"
  if [ -f "${strPathOfFileToBackup}" ]; then
    local strFileName="${strPathOfFileToBackup##*/}"
    local strFileDirectory="${strPathOfFileToBackup%/*}"
    mkdir -pv "${strPathOfFolderToPlaceBackupIn}${strFileDirectory}"
    sudo cp -nv "${strPathOfFileToBackup}" "${strPathOfFolderToPlaceBackupIn}${strPathOfFileToBackup}"
    sudo chown -cR "${strUser}:${strUser}" "${strPathOfFolderToPlaceBackupIn}"
    sudo chmod -cR go-rwx "${strPathOfFolderToPlaceBackupIn}"
  fi
}
#
function backupFolder
{
  local strUser="$1"
  local strPathOfFolderToPlaceBackupIn="$2"
  local strPathOfFolderToBackup="$3"
  if [ -d "${strPathOfFolderToBackup}" ]; then
    mkdir -pv "${strPathOfFolderToPlaceBackupIn}${strPathOfFolderToBackup}"
    #set +f
    #sudo cp -nvr "${strPathOfFolderToBackup}"/* "${strPathOfFolderToPlaceBackupIn}${strPathOfFolderToBackup}"
    #set -f
    sudo cp -nvr "${strPathOfFolderToBackup}" "${strPathOfFolderToPlaceBackupIn}${strPathOfFolderToBackup%/*}"
    sudo chown -cR "${strUser}:${strUser}" "${strPathOfFolderToPlaceBackupIn}"
    sudo chmod -cR go-rwx "${strPathOfFolderToPlaceBackupIn}"
  fi
}
#
function backupFileSystemObjects
{
  local strUser="$1"
  local strPathOfFolderToPlaceBackupIn="$2"
 
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/usr/bin/firefox"
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/etc/fstab"
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/etc/default/grub"
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.bash_history"
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.profile"
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.bashrc"
  backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.bash_logout"

  if [ -d "/root/.config/bcompare" ]; then
    backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/root/.config/bcompare/BCSessions.xml"
    backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/root/.config/bcompare/BC3Key.txt"
  fi

  if [ -d "/home/${strUser}/.config/bcompare" ]; then
    backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.config/bcompare/BCSessions.xml"
    backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.config/bcompare/BCFtpProfiles.xml"
    backupFile "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/home/${strUser}/.config/bcompare/BC3Key.txt"
  fi

  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/usr/share/nemo/actions"
  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/etc/lightdm"
  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/etc/yum.repos.d"
  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/etc/apt"  
  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/etc/gdm"
  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/usr/share/X11/xorg.conf.d"
  backupFolder "${strUser}" "${strPathOfFolderToPlaceBackupIn}" "/var/log/installer"
}
#
function backupDConf
{
  local strUserSettings="$1"
  local strUserOwner="$2"
  local strPathOfFileToPlaceBackupIn="$3"
  sudo -u "${strUserSettings}" gsettings list-recursively > "${strPathOfFileToPlaceBackupIn}"
  if [ ! "${strUserSettings}" = "${strUserOwner}" ]; then
    sudo chown -v "${strUserOwner}:${strUserOwner}" "${strPathOfFileToPlaceBackupIn}"
  fi
}
#
function backupInstalledPackagesAPT
{
  local strUser="$1"
  local strPathOfFileToPlaceBackupIn="$2"
  set +e
  sudo apt list --installed 2>/dev/null > ${strPathOfFileToPlaceBackupIn}
  set -e
  sudo chown -R "${strUser}:${strUser}" "${strPathOfFileToPlaceBackupIn}"
  sudo chmod -R go-rwx "${strPathOfFileToPlaceBackupIn}"
}
#
function backupInstalledPackagesDPKG
{
  local strUser="$1"
  local strPathOfFileToPlaceBackupIn="$2"
  sudo dpkg --get-selections > ${strPathOfFileToPlaceBackupIn}
  sudo chown -R "${strUser}:${strUser}" "${strPathOfFileToPlaceBackupIn}"
  sudo chmod -R go-rwx "${strPathOfFileToPlaceBackupIn}"
}
#
function backupInstalledPackagesDNF
{
  local strUser="$1"
  local strPathOfFileToPlaceBackupIn="$2"
  sudo dnf list installed  > ${strPathOfFileToPlaceBackupIn}
  sudo chown -R "${strUser}:${strUser}" "${strPathOfFileToPlaceBackupIn}"
  sudo chmod -R go-rwx "${strPathOfFileToPlaceBackupIn}"  
}


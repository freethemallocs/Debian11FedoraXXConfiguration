#!/bin/bash

source "${0%/*}/library.os.sh"
source "${0%/*}/library.backup.sh"
source "${0%/*}/library.fso.sh"

umask 077

set -e
set -f
set -u

################################################################################
# When we launch the script in a certain way we run into problems. We need to
# launch script in a certain way so that we can easily authenticate as root
################################################################################
if [[ "$0" =~ .?bash ]] ; then
  echo "[ERROR] unable to parse command line. try launching script from within directory that script resides (i.e. ./scriptname.sh)"
  exit 8
fi 

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
# Get details about the operating system
################################################################################
strOperatingSystemName=$(echoOperatingSystemName)
strOperatingSystemVersionNumber=$(echoOperatingSystemVersionNumber)

################################################################################
# Create a temporary directory to put results in
################################################################################
strBackupDirectoryPath=$(createDeterministicFileSystemDirectoryPath -ymd -hms "${strOperatingSystemName}" "v${strOperatingSystemVersionNumber}" "backup")

################################################################################
# Backup file system objects
################################################################################
mkdir -pv "${strBackupDirectoryPath}/files"
backupFileSystemObjects "${strUser}" "${strBackupDirectoryPath}/files"

################################################################################
# Log the state of DConf database
################################################################################
backupDConf "${strUser}" "${strUser}" "${strBackupDirectoryPath}/dconf.log.${strUser}.txt"
if [ ! "root" = "${strUser}" ]; then
  backupDConf "root" "${strUser}" "${strBackupDirectoryPath}/dconf.log.root.txt"
fi

################################################################################
# Backup list of programs
################################################################################
if [ "fedora" = "${strOperatingSystemName}" ]
then
     backupInstalledPackagesDNF "${strUser}" "${strBackupDirectoryPath}/packages.dnf.txt"
fi
if [ "debian" = "${strOperatingSystemName}" ]
then
     backupInstalledPackagesAPT "${strUser}" "${strBackupDirectoryPath}/packages.apt.txt"
     backupInstalledPackagesDPKG "${strUser}" "${strBackupDirectoryPath}/packages.dpkg.txt"
fi


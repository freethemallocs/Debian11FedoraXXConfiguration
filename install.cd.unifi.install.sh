#!/bin/bash

source "${0%/*}/library.packages.sh"
#source "${0%/*}/install.#.configuration.sh"

umask 077

set -e
set -f
set -u

################################################################################
# https://www.ui.com/download/unifi/default/default/unifi-network-application-7166-debianubuntu-linux-and-unifi-cloud-key
################################################################################
strFilePathPackage="unifi_sysvinit_all.deb"
strPackageNameDisplay="unifi"
strPackageNameDPKG=$(echoPackageNameDPKG "${strFilePathPackage}")

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
# Check to see if package is installed
################################################################################
if (isPackageInstalled "${strPackageNameDPKG}"); then
  echo "[WARNING] ${strPackageNameDisplay} is installed"
  read -p "Uninstall ${strPackageNameDisplay} (Y/N)? " strResult
  if [[ "${strResult}" =~ ^[Yy].*$ ]]; then
    removePackage "${strPackageNameDPKG}"
  else
    echo "[ERROR] Failed to install ${strFilePathPackage##*/}"
    exit 8
  fi
fi

################################################################################
# List dependencies for package
###############################################################################
echo "Dependencies for package ${strFilePathPackage##*/} are listed as follows:"
dpkg-deb --info "${strFilePathPackage}" | grep -i -G "^ *Depends: *" | sed "s/^ *Depends://Ig"  | sed "s/^ *//g" | sed "s/ *$//g"

################################################################################
# Check to see if dependencies are installed
# Attempt installation if dependencies not yet installed
################################################################################
if (arePackageDependenciesforLocalFilePathInstalledDPKG "${strFilePathPackage}"); then
     echo "[NOTE] All dependencies are installed for ${strFilePathPackage##*/}"
else
     installPackageDependenciesforLocalFilePathAPT "${strFilePathPackage}"

     if (arePackageDependenciesforLocalFilePathInstalledDPKG "${strFilePathPackage}"); then
          echo "[NOTE] All dependencies are installed for ${strFilePathPackage##*/}"
     else
          echo "[ERROR] Missing dependencies for ${strFilePathPackage##*/}"
          exit 8
     fi
fi

################################################################################
# Install package
################################################################################
installPackageViaLocalFile "${strPackageNameDPKG}" "${strFilePathPackage}"
#sudo apt-get install --fix-missing
#sudo apt-get --fix-broken install



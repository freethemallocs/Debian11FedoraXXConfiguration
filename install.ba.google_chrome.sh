#!/bin/bash

source "${0%/*}/library.packages.sh"
source "${0%/*}/install.#.configuration.sh"

umask 077

set -e
set -f
set -u

strFilePathPackage="${strFilePathGoogleChromeInstallationPackage}"
strPackageNameDisplay="google chrome"
strPackageNameDPKG=$(echoPackageNameDPKG "${strFilePathPackage}")

# sudo apt-get install -y libu2f-udev

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

#!/bin/bash

source "${0%/*}/library.packages.sh"
source "${0%/*}/install.#.configuration.sh"

umask 077

set -e
set -f
set -u

################################################################################
# https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux
# https://support.zoom.us/hc/en-us/articles/205759689-Release-notes-for-Linux
################################################################################
#January 9, 2023 version 5.13.4 (711)
strFilePathPackage="${strFilePathZoomInstallationPackage}"
strPackageNameDisplay="zoom"
strPackageNameDPKG=$(echoPackageNameDPKG "${strFilePathPackage}")

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
# Clean up prior configuration files
################################################################################
if [ -d "${HOME}/.zoom" ]; then
  rm -vR ${HOME}/.zoom
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
# Does not need to be installed according to documentation
# However zoom debian package lists it as a dependency
################################################################################
#sudo apt-get install -y libegl1-mesa
#sudo apt-get install -y libxcb-xinerama0
#sudo apt-get install -y libxkbcommon-x11-0
#sudo apt-get install -y libxcb-cursor0

################################################################################
# Does needs to be installed according to documentation
################################################################################
#sudo apt-get install -y libglib2.0-0
## ?? sudo apt-get install -y libgstreamer-plugins-base0.10-0 
#sudo apt-get install -y libxcb-shape0
#sudo apt-get install -y libxcb-shm0
#sudo apt-get install -y libxcb-xfixes0
#sudo apt-get install -y libxcb-randr0
#sudo apt-get install -y libxcb-image0
#sudo apt-get install -y libfontconfig1
#sudo apt-get install -y libgl1-mesa-glx
#sudo apt-get install -y libxi6
#sudo apt-get install -y libsm6
#sudo apt-get install -y libxrender1
#sudo apt-get install -y libpulse0
#sudo apt-get install -y libxcomposite1
#sudo apt-get install -y libxslt1.1
#sudo apt-get install -y libsqlite3-0
#sudo apt-get install -y libxcb-keysyms1
#sudo apt-get install -y libxcb-xtest0
#sudo apt-get install -y ibus

################################################################################
# Install package
################################################################################
installPackageViaLocalFile "${strPackageNameDPKG}" "${strFilePathPackage}"

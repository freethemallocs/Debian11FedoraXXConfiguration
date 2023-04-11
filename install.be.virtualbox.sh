#!/bin/bash

source "${0%/*}/library.os.sh"
source "${0%/*}/library.packages.sh"
source "${0%/*}/install.#.configuration.sh"

umask 077

set -e
set -f
set -u

################################################################################
# https://
################################################################################
strPackageNameDisplay="virtual box"
strPackageNameDPKG="virtualbox-${strVersionVirtualBoxToInstall}"
versionName=$(echoOperatingSystemVersionName)

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
# Download and install public key
################################################################################
echo "Debian version name is: ${versionName}"
set +e
strAptSourcesConfigurationLine=$(sudo cat ${strAptSourcesConfigurationPathFile} | grep -i "virtualbox")
set -e
if [ "${#strAptSourcesConfigurationLine}" -gt 0 ]; then
   echo "${strAptSourcesConfigurationLine}"
   echo "[NOTE] Virtual box repository already appended to ${strAptSourcesConfigurationPathFile}"
else    
   strAptSourcesConfigurationLine="deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian ${versionName} contrib"
   sudo su -c "echo '${strAptSourcesConfigurationLine}' >> ${strAptSourcesConfigurationPathFile}"
   
   set +e
   strAptSourcesConfigurationLine=$(sudo cat ${strAptSourcesConfigurationPathFile} | grep -i "virtualbox")
   set -e
   
   if [ "${#strAptSourcesConfigurationLine}" -eq 0 ]; then
       echo "[ERROR] Failed to add virtual box repository to ${strAptSourcesConfigurationPathFile}"
   else
       echo "${strAptSourcesConfigurationLine}"
       echo "[NOTE] Added virtual box repository to ${strAptSourcesConfigurationPathFile}"
       
   fi
fi

################################################################################
# Trust key for package
################################################################################
#if [ ! -f "/usr/share/keyrings/oracle-virtualbox.gpg" ]; then
#     wget -O- https://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox.gpg
#     sudo chmod ugo+r /usr/share/keyrings/oracle-virtualbox.gpg
#fi
if [ ! -f "/usr/share/keyrings/oracle-virtualbox-2016.gpg" ]; then
     wget -O- https://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
     sudo chmod ugo+r /usr/share/keyrings/oracle-virtualbox-2016.gpg
fi

################################################################################
# Install package
################################################################################
if [ "${#strAptSourcesConfigurationLine}" -gt 0 ]; then
     sudo apt-get update
     sudo apt-get install -y "${strPackageNameDPKG}"
fi

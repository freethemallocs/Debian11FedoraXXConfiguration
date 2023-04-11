#!/bin/bash

source "${0%/*}/library.packages.sh"
source "${0%/*}/install.#.configuration.sh"

umask 077

set -e
set -f
set -u

################################################################################
# https://download.spotify.com/
################################################################################
strPackageNameDisplay="spotify"
strPackageNameDPKG="spotify-client"

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
if [ -d "${HOME}/.config/spotify" ]; then
  rm -vR ${HOME}/.config/spotify
fi

################################################################################
# Download and install public key
################################################################################
# sudo wget -O- https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - 
sudo wget -O- https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee ${strAptSourcesConfigurationPathDirectory}/spotify.list

################################################################################
# Install spotify
################################################################################
sudo apt-get update
sudo apt-get install -y "${strPackageNameDPKG}"


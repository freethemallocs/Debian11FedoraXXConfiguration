#!/bin/bash

source "${0%/*}/library.packages.sh"

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
# Install frequently used tools
################################################################################
functionUpgrade

################################################################################
# Install mongodb from Debian stretch
################################################################################
sudo apt-get -t stretch install -y mongodb

################################################################################
# Cache all the packages we have installed
################################################################################

strCurrentDirectory="${HOME}/packages"
mkdir -pv "${strCurrentDirectory}"

cd "${strCurrentDirectory}"

strCommand="mkdir -pv \"${strCurrentDirectory}\${0%/*}\""
sudo find /var/cache/apt/archives -type f -iname "*.deb" -exec bash -c "${strCommand}" {} \;

strCommand="cp -fv \"\${0}\" \"${strCurrentDirectory}\${0}\""
sudo find /var/cache/apt/archives -type f -iname "*.deb" -exec bash -c "${strCommand}" {} \;

sudo chown $(whoami):$($whoami) -vR *
sudo chmod go-rwx -vR *

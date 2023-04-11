#!/bin/bash

################################################################################
# Common install libraries are intentionally not used in this script
# because it is the very first script to run and sudo might not be installed yet
################################################################################

umask 077

set -e
set -f
set -u

################################################################################
# When we launch the script in a certain way we run into problems. We need to
# launch script in a certain way so that we can easily authenticate as root
################################################################################
if [[ "${0}" =~ .?bash ]] ; then
  echo "[ERROR] unable to parse command line. try launching script from within directory that script resides (i.e. ./scriptname.sh)"
  exit 8
fi 

################################################################################
# Authenticate as root
################################################################################
strUserCurrent="$(whoami)"
if [ ! "root" = "${strUserCurrent}" ]; then
  echo "Authenticate as root"
  su -c "./${0} ${strUserCurrent}"
  exit 0
fi

################################################################################
# Get user passed in as a parameter
################################################################################
strUserParameter="$(whoami)"
if [ "$#" -gt 0 ]; then
  strUserParameter="${1}"
fi

################################################################################
# Verify a non root user is specified as a parameter
################################################################################
if [ "root" = "${strUserParameter}" ]; then
  echo "[ERROR] A user that is not root must be specified as the first parameter to this script"
  exit 8
fi

################################################################################
# Setup ability to install mongodb from Debian 9 Codename Stretch
# https://unix.stackexchange.com/questions/60555/debian-is-it-possible-safe-to-install-packages-from-an-older-version-of-the-rep
################################################################################
echo "deb http://ftp.us.debian.org/debian/ stretch main" > /etc/apt/sources.list.d/stretch.list
echo "deb-src http://ftp.us.debian.org/debian/ stretch main" >> /etc/apt/sources.list.d/stretch.list
echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list.d/stretch.list
echo "deb-src http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list.d/stretch.list 
echo "APT::Default-Release \"bullseye\";" > /etc/apt/apt.conf.d/99stretch
apt-get update


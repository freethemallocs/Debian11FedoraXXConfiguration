#!/bin/bash

source "${0%/*}/install.#.configuration.sh"

umask 077

set -e
set -f
set -u

strHostNameBefore="${HOSTNAME}"
strHostNameDesired="${strNewHostName}"

################################################################################
# When we launch the script in a certain way we run into problems. We need to
# launch script in a certain way so that we can easily authenticate as root
################################################################################
if [[ "${0}" =~ .?bash ]] ; then
  echo "[ERROR] unable to parse command line. try launching script from within directory that script resides (i.e. ./scriptname.sh)"
  exit 8
fi 

################################################################################
# Check to make sure hostname actually needs changing
################################################################################
if [ "${strHostNameBefore}" = "${strHostNameDesired}" ]; then
  echo "Hostname is ${strHostNameBefore} and does not need to be changed"
  exit 0
fi

################################################################################
# Authenticate as root
################################################################################
strUser="$(whoami)"
if [ ! "root" = "${strUser}" ]; then
  echo "Authenticate as root"
  su -c "./${0} ${strUser}"
  exit 0
fi

################################################################################
# Change hostname Using Debian Script
################################################################################
/usr/bin/hostnamectl set-hostname "${strHostNameDesired}"

################################################################################
# Change hostname in configuration file
################################################################################
sed -i "s/[0-9.]* *${strHostNameBefore}/${strHostNameDesired}/g" /etc/hosts

################################################################################
# Get hostname in configuration file after change
################################################################################
set +e
strHostNameAfter=$(hostnamectl | grep -io "Static hostname:.*" | sed 's/^Static hostname://g' | sed 's/ //g')
set -e

echo "File /etc/hosts is as follows:"
cat /etc/hosts
echo " "

################################################################################
# Restart machine to apply changes
################################################################################
if [ "${strHostNameDesired}" = "${strHostNameAfter}" ]; then
     echo "Hostname changed from ${strHostNameBefore} to ${strHostNameDesired}"
     sudo /sbin/shutdown -r 60
     echo "A restart of the system is needed to apply changes"
     read -p "Restart system (Y/N)? " strResult
     if [[ "${strResult}" =~ ^[Nn].*$ ]]; then
       sudo /sbin/shutdown -c
       echo "System not restarted"
       echo "Please restart system later"
     else
       sudo /sbin/shutdown -r now
     fi
else
  echo "[ERROR] Failed to change hostname from ${strHostNameBefore} to ${strHostNameDesired}"
fi



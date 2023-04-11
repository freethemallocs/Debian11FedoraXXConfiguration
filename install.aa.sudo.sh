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
# Make sure sudo tool is installed
################################################################################
strOperatingSystemName=$(cat /etc/os-release | grep -i "^ID=" | grep -io "=.*$" | sed 's/=//g' | sed 's/"//g')

if [ "fedora" = "${strOperatingSystemName}" ]
then
   dnf install -y sudo
fi
if [ "debian" = "${strOperatingSystemName}" ]
then
   apt-get install -y sudo
fi

################################################################################
# Add user to group of sudoers
################################################################################
echo "/usr/sbin/usermod -aG sudo \"${strUserParameter}\""
/usr/sbin/usermod -aG sudo "${strUserParameter}"

################################################################################
# Verify we added user correctly to group of sudoers
################################################################################
set +e
strUsermodTestResult=$(cat /etc/group | grep -io "^sudo.*[,:]\?${strUserParameter}[,]\?" | grep -io "[,:]\?${strUserParameter}[,]\?"  | grep -io "${strUserParameter}")
set -e
if [ "${strUsermodTestResult}" = "${strUserParameter}" ]; then
  echo "Added ${strUserParameter} to sudoers group"
  echo "A restart of the system is needed"
  /sbin/shutdown -r 60
  read -p "Press any key to restart the system..."
  /sbin/shutdown -r now
else
  echo "[ERROR] Failed to add ${strUserParameter} to sudoers group"
fi


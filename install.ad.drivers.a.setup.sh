#!/bin/bash

################################################################################
# Automate adding non-free for debian 11 and non-free-firmare for debian 12 to install sources.list script
# https://wiki.debian.org/SourcesList
################################################################################

source "${0%/*}/library.os.sh"
source "${0%/*}/library.fso.sh"
source "${0%/*}/install.#.configuration.sh"

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
  su -c "./${0} ${strUserCurrent} $HOME"
  exit 0
fi

################################################################################
# Get user passed in as a parameter
################################################################################
strUserParameter="$(whoami)"
strHomeDirectoryPath="$HOME"
if [ "$#" -gt 0 ]; then
  strUserParameter="${1}"
  strHomeDirectoryPath=$(eval echo "~${strUserParameter}")
  if [ ! -d "${strHomeDirectoryPath}" ]; then
     strHomeDirectoryPath="$HOME"
  fi
fi

################################################################################
# Get home directory path passed in as a parameter
################################################################################
if [ "$#" -gt 1 ]; then
  if [ -d "${2}" ]; then
     strHomeDirectoryPath="${2}"
  fi
fi

################################################################################
# get OS configuration variables
################################################################################
strOperatingSystemName=$(echoOperatingSystemName)
strOperatingSystemVersionNumber=$(echoOperatingSystemVersionNumber)
strOperatingSystemVersionName=$(echoOperatingSystemVersionName)
echo "Operating system name is ${strOperatingSystemName}"
echo "Operating system version number is ${strOperatingSystemVersionNumber}"
echo "Operating system version name is ${strOperatingSystemVersionName}"

################################################################################
# Save off sources.list before we change it
################################################################################
strAptSourcesConfigurationPathFileBefore=$(getDeterministicFileSystemObjectPath -d "${strHomeDirectoryPath}" -ymd -hms "${strOperatingSystemName}" "v${strOperatingSystemVersionNumber}" "etc.apt.sources.list.before")
cat "${strAptSourcesConfigurationPathFile}" > "${strAptSourcesConfigurationPathFileBefore}"
chown -cR "${strUserParameter}:${strUserParameter}" "${strAptSourcesConfigurationPathFileBefore}"
chmod -cR go-rwx "${strAptSourcesConfigurationPathFileBefore}"

################################################################################
# the following is needed to install non-free firmware
################################################################################
if [ "debian" = "${strOperatingSystemName}" ]; then
     if [ "${strOperatingSystemVersionNumber}" -eq 11 ]; then
          sed -i "/^#/! {/^deb / s/ *${strOperatingSystemVersionName} *main *$/ ${strOperatingSystemVersionName} main non-free/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb-src / s/ *${strOperatingSystemVersionName} *main *$/ ${strOperatingSystemVersionName} main non-free/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb / s/ *${strOperatingSystemVersionName}-security *main *$/ ${strOperatingSystemVersionName}-security main non-free/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb-src / s/ *${strOperatingSystemVersionName}-security *main *$/ ${strOperatingSystemVersionName}-security main non-free/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb / s/ *${strOperatingSystemVersionName}-updates *main *$/ ${strOperatingSystemVersionName}-updates main non-free/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb-src / s/ *${strOperatingSystemVersionName}-updates *main *$/ ${strOperatingSystemVersionName}-updates main non-free/g}" "${strAptSourcesConfigurationPathFile}"
     fi
     if [ "${strOperatingSystemVersionNumber}" -eq 12 ]; then
          sed -i "/^#/! {/^deb / s/ *${strOperatingSystemVersionName} *main *$/ ${strOperatingSystemVersionName} main non-free-firmware/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb-src / s/ *${strOperatingSystemVersionName} *main *$/ ${strOperatingSystemVersionName} main non-free-firmware/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb / s/ *${strOperatingSystemVersionName}-security *main *$/ ${strOperatingSystemVersionName}-security main non-free-firmware/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb-src / s/ *${strOperatingSystemVersionName}-security *main *$/ ${strOperatingSystemVersionName}-security main non-free-firmware/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb / s/ *${strOperatingSystemVersionName}-updates *main *$/ ${strOperatingSystemVersionName}-updates main non-free-firmware/g}" "${strAptSourcesConfigurationPathFile}"
          sed -i "/^#/! {/^deb-src / s/ *${strOperatingSystemVersionName}-updates *main *$/ ${strOperatingSystemVersionName}-updates main non-free-firmware/g}" "${strAptSourcesConfigurationPathFile}"
     fi
fi

################################################################################
# Save off sources.list after we change it
################################################################################
strAptSourcesConfigurationPathFileAfter=$(getDeterministicFileSystemObjectPath -d "${strHomeDirectoryPath}" -ymd -hms "${strOperatingSystemName}" "v${strOperatingSystemVersionNumber}" "etc.apt.sources.list.after")
cat "${strAptSourcesConfigurationPathFile}" > "${strAptSourcesConfigurationPathFileAfter}"
chown -cR "${strUserParameter}:${strUserParameter}" "${strAptSourcesConfigurationPathFileAfter}"
chmod -cR go-rwx "${strAptSourcesConfigurationPathFileAfter}"

################################################################################
# Deterime if we need an update
################################################################################
if($(diff "${strAptSourcesConfigurationPathFileBefore}" "${strAptSourcesConfigurationPathFileAfter}" > /dev/null)); then
  echo "Compare the following two files to review changes to ${strAptSourcesConfigurationPathFile}:"
  echo "${strAptSourcesConfigurationPathFileBefore}"
  echo "${strAptSourcesConfigurationPathFileAfter}"
  echo "[NOTE] No changes were made to ${strAptSourcesConfigurationPathFile}"
else
     ################################################################################
     # Changes were made to sources.list, we will need an update
     ################################################################################
     apt-get update
     
     ################################################################################
     # Compare the before and after files
     ################################################################################
     echo "Compare the following two files to review changes to ${strAptSourcesConfigurationPathFile}:"
     echo "${strAptSourcesConfigurationPathFileBefore}"
     echo "${strAptSourcesConfigurationPathFileAfter}"
     echo "Attempting to print differences:"
     set +e
     diff "${strAptSourcesConfigurationPathFileBefore}" "${strAptSourcesConfigurationPathFileAfter}"
     set -e
fi

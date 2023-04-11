#!/bin/bash

umask 077

set -e
set -f
set -u

#strVirtualMachineRole="host"
#strVirtualMachineRole="guest"
#strVirtualMachineRole="host"

strDirectoryPathProject="${0%/*}"

if [ "${#OSTYPE}" -gt 0 ]; then
    strOperatingSystem="$OSTYPE"
elif [ "$(uname -o)" -eq "GNU/Linux" ]; then
    strOperatingSystem="linux-gnu"
fi

#echo "Virtual machine role: $strVirtualMachineRole"

#strVirtualMachineRoleRequired="host"
#if [ "${strVirtualMachineRoleRequired}" = "${strVirtualMachineRole}" ]; then
#  strDirectoryPathConfiguration="${strDirectoryPathProject}/configuration.host"
#else
#  strDirectoryPathConfiguration="${strDirectoryPathProject}/configuration.guest"
#fi

strVersionVirtualBoxToInstall="6.1"

strNewHostName="GrottoDelDiablo"
strHTTPPathNetBeansInstaller="https://dlcdn.apache.org/netbeans/netbeans-installers/14/Apache-NetBeans-14-bin-linux-x64.sh"
strFilePathGoogleChromeInstallationPackage="google-chrome-stable_current_amd64.deb"
strFilePathBeyondCompareInstallationPackage="bcompare-4.4.6.27483_amd64.deb"
strFilePathZoomInstallationPackage="zoom_amd64.v5_13_4_711.deb"
strAptSourcesConfigurationPathFile="/etc/apt/sources.list"
strAptSourcesConfigurationPathDirectory="/etc/apt/sources.list.d"


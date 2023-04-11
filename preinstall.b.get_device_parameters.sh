#!/bin/bash

source "${0%/*}/library.fso.sh"
source "${0%/*}/preinstall.#.configuration.sh"

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
# Get path of configuration to append results to
################################################################################
strConfigurationFilePath="${0%/*}/preinstall.#.configuration.sh"

################################################################################
# Comment out parameters we are trying to derive
################################################################################
if [ -f "${strConfigurationFilePath}" ]; then
    sed -i "s/^strDeviceName *= */#strDeviceName=/g" "${strConfigurationFilePath}"
    sed -i "s/^strPartitionName *= */#strPartitionName=/g" "${strConfigurationFilePath}"
fi

################################################################################
# 1) Your flash drive must have a single partition with a vfat file system.
#    To determine how it is formatted, follow these steps:

#    1a) Find the name of this partition and the device itself by running 
#        dmesg shortly after connecting the drive. The device name (similar 
#        to /dev/sdc) and the partition name (similar to /dev/sdc1) both 
#        appear in several lines towards the end of the output.
#        Example -> " sdb: sdb1"
#                -> "SELinux: initialized (dev sdb1, type vfat), uses genfs_contexts
################################################################################

strTempPathBefore=$(getDeterministicFileSystemObjectPath -ymd -hms "deviceNamesBefore.txt")
sudo dmesg > "${strTempPathBefore}"

echo "Connect USB Drive then press any key..."
read

strTempPathAfter=$(getDeterministicFileSystemObjectPath -ymd -hms "deviceNamesAfter.txt")
sudo dmesg > "${strTempPathAfter}"

set +e

strDifferences=$(diff -i "${strTempPathBefore}" "${strTempPathAfter}")

if [ "${#strDifferences}" -gt 0 ]; then
    echo "Compare the following two files to get the device name:"
    echo "${strTempPathBefore}"
    echo "${strTempPathAfter}"
    echo "Attempting to print differences:"
    diff -i "${strTempPathBefore}" "${strTempPathAfter}"

    strGrepResultA=$(echo $strDifferences | grep -io "sd[a-z]: sd[a-z][0-9]")
    strGrepResultB=$(echo $strDifferences | grep -io "sd[a-z]: *")

    if [ "${#strGrepResultA}" -gt 0 ]; then
        strDeviceName="/dev/${strGrepResultA:0:3}"
        strPartitionName="/dev/${strGrepResultA:5:4}"
        echo "Suggested device name is: ${strDeviceName}"
        echo "Suggested partition name is: ${strPartitionName}"
        echo "strDeviceName=\"${strDeviceName}\"" >> "${strConfigurationFilePath}"
        echo "strPartitionName=\"${strPartitionName}\"" >> "${strConfigurationFilePath}"
    elif [ "${#strGrepResultB}" -gt 0 ]; then
        strDeviceName="/dev/${strGrepResultB:0:3}"
        strPartitionName="/dev/${strGrepResultB:0:3}1"
        echo "Suggested device name is: ${strDeviceName}"
        echo "Suggested partition name is: ${strPartitionName}"
        echo "strDeviceName=\"${strDeviceName}\"" >> "${strConfigurationFilePath}"
        echo "strPartitionName=\"${strPartitionName}\"" >> "${strConfigurationFilePath}"
    fi

else
    echo "Compare the following two files to get the device name:"
    echo "${strTempPathBefore}"
    echo "${strTempPathAfter}"
    echo "ERROR: Failed to determine the device name"
fi


#!/bin/bash

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

###############################################################################
# 1b) Use the partition/device name to ensure that the file system type of
#     the USB flash drive is vfat. You should now see a message similar to:
#     LABEL="LIVE" UUID="6676-27D3" TYPE="vfat"
###############################################################################
set +e
echo "sudo blkid \"${strDeviceName}\""
sudo blkid "${strDeviceName}"
strDeviceType=$(sudo blkid "${strDeviceName}" | grep -io " TYPE=[\"][a-z0-9]*[\"]" | sed 's/ TYPE=//g' | sed 's/"//g')
set -e

###############################################################################
  # 1c) If TYPE is anything other than vfat (for example, TYPE="iso9660"), 
  #     clear the first blocks of the USB flash drive:
###############################################################################
if [[ "vfat" != "${strDeviceType}" ]] ; then
  echo "Device type for ${strDeviceName} is not vfat"
  echo "sudo dd if=/dev/zero of=\"${strPartitionName}\" bs=1M count=100"
  sudo dd if=/dev/zero of="${strPartitionName}" bs=1M count=100
fi

###############################################################################
# 2) Use the dd command to transfer the boot ISO image to the USB device:
#    Ensure you specify the device name, not the partition name. For example:
#    dd if=~/Download/Fedora-17-x86_64-DVD.iso of=/dev/sdc
###############################################################################
echo "sudo dd if=\"$strPathISO\" of=\"$strDeviceName\""
sudo dd if="$strPathISO" of="$strDeviceName" status=progress


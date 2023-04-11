#!/bin/bash

source "${0%/*}/library.os.sh"

umask 077

set -e
set -f
set -u

osName=$(echoOperatingSystemName)
versionName=$(echoOperatingSystemVersionName)
versionOS=$(echoOperatingSystemVersionNumber)
strOperatingSystemType=$(echoOperatingSystemType)

echo "Operating system is ${osName}"
echo "Version name of operating system is $versionName"
echo "Version number of operating system is $versionOS"
echo "Machine (hardware) type: $(uname -m)"
echo "Machine's network node hostname: $(uname -n)"
echo "Machine's processor type: $(uname -p)"
echo "Kernel release: $(uname -r)"
echo "Kernel name: $(uname -s)"
echo "Kernel version: $(uname -v)"
echo "Hardware platform or "unknown": $(uname -i)"
echo "Operating system: $strOperatingSystemType"


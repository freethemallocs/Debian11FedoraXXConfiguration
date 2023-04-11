#!/bin/bash

source "${0%/*}/library.fso.sh"

umask 077

set -e
set -f
set -u

strDirectoryPathInput="$(pwd)"
strDirectoryPathOutput="${HOME}"

################################################################################
# Create a temporary directory to put files in
################################################################################
strTemporaryDirectoryPath=$(createDeterministicFileSystemDirectoryPath "temp" -ymd -hms "iso" "files")

################################################################################
# Get a name for a temporary file to put files in
################################################################################
strFilePathOutput=$(getDeterministicFileSystemObjectPath "install" "files" "${strDirectoryPathInput##*/}" -ymd -hms "iso")

################################################################################
# Copy over relevant files
################################################################################
set +f
cp -nv "${strDirectoryPathInput}"/*.sh "${strTemporaryDirectoryPath}"
cp -nv "${strDirectoryPathInput}"/*.deb "${strTemporaryDirectoryPath}"
cp -nv "${strDirectoryPathInput}"/*.txt "${strTemporaryDirectoryPath}"
set -f

################################################################################
# Create iso image
################################################################################
echo "genisoimage -o \"${strFilePathOutput}\" \"${strTemporaryDirectoryPath}\""
genisoimage -iso-level 4 -o "${strFilePathOutput}" "${strTemporaryDirectoryPath}"

################################################################################
# Delete temporary files
################################################################################
rm -fvr "${strTemporaryDirectoryPath}"

################################################################################
# Announce completion
################################################################################
echo "[NOTE] Created file ${strFilePathOutput}"

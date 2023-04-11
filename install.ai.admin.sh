#!/bin/bash

umask 077

set -e
set -f
set -u

function setupAppendPathVariableOperation
{
    local strLibraryPath="${1}"
    local strDescription="${2}"
    local strFilePath="${3}"

     if [ -f "${strFilePath}" ] ; then
          echo " " >> "${strFilePath}"
          echo "${strDescription}" >> "${strFilePath}"
          echo "if [ -n \"\${BASH_VERSION}\" ]; then" >> "${strFilePath}"
          echo "  if [[ \"\${PATH}\" = \"${strLibraryPath}\" ]] ; then" >> "${strFilePath}"
          echo "    :" >> "${strFilePath}"
          echo "  elif [[ \"\${PATH}\" =~ :${strLibraryPath}$ ]] ; then" >> "${strFilePath}"
          echo "    :" >> "${strFilePath}"
          echo "  elif [[ \"\${PATH}\" =~ ^${strLibraryPath}: ]] ; then" >> "${strFilePath}"
          echo "    :" >> "${strFilePath}"
          echo "  elif [[ \"\${PATH}\" =~ :${strLibraryPath}: ]] ; then" >> "${strFilePath}"
          echo "    :" >> "${strFilePath}"
          echo "  elif [ -d \"${strLibraryPath}\" ] ; then" >> "${strFilePath}"
          echo "    PATH=\"\${PATH}:${strLibraryPath}\"" >> "${strFilePath}"
          echo "  fi" >> "${strFilePath}"
          echo "fi" >> "${strFilePath}"
     fi
}

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
# Allow us to call administrative tools easily (like ifconfig) when logging in
################################################################################
setupAppendPathVariableOperation "/sbin" "# set PATH so user can call administrative tools easily" "${HOME}/.profile"
echo "Contents of ${HOME}/.profile to follow:"
cat "${HOME}/.profile"

################################################################################
# Allow us to call administrative tools easily (like ifconfig) via terminal
################################################################################
if [ -f "${HOME}/.bashrc" ] ; then
     setupAppendPathVariableOperation "/sbin" "# set PATH so user can call administrative tools easily" "${HOME}/.bashrc"
     echo "Contents of ${HOME}/.bashrc to follow:"
     cat "${HOME}/.bashrc"
fi


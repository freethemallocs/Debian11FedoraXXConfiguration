#!/bin/bash

umask 077

set -e
set -f
set -u

function echoOperatingSystemType
{
     if [ "${#OSTYPE}" -gt 0 ]; then
         echo "$OSTYPE"
     elif [ "$(uname -o)" -eq "GNU/Linux" ]; then
         echo "linux-gnu"
     else
          echo "unknown"
     fi
}

function echoOperatingSystemName
{
    cat /etc/os-release | grep -i "^ID=" | grep -io "=.*$" | sed 's/=//g' | sed 's/"//g'
}

function echoOperatingSystemVersionName
{
    cat /etc/os-release | grep -i "^VERSION_CODENAME=" | grep -io "=.*$" | sed 's/=//g' | sed 's/"//g'
}

function echoOperatingSystemVersionNumber
{
    cat /etc/os-release | grep -i "^VERSION_ID=" | grep -io "=.*$" | sed 's/=//g' | sed 's/"//g'
}


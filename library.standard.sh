#!/bin/bash

umask 077

set -e
set -u
set -f

#
function formatInteger02
{
    local strUnsignedInteger="${1}"
    local strInputCheckResult=$(echo "${strUnsignedInteger}" | sed 's/[0-9]//g')
    local strReturn=""

    if [ "${#strInputCheckResult}" -gt 0 ]; then
        echo "ERROR: Input to formatInteger02 is not an unsigned integer"
        return 1
    else
        if [ "${#strUnsignedInteger}" -ge 2 ]; then
          strReturn="${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 1 ]; then
          strReturn="0${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 0 ]; then
          strReturn="00"
        fi
    fi    

    echo "${strReturn}"
}
#
function formatInteger04
{
    local strUnsignedInteger="${1}"
    local strInputCheckResult=$(echo "${strUnsignedInteger}" | sed 's/[0-9]//g')
    local strReturn=""

    if [ "${#strInputCheckResult}" -gt 0 ]; then
        echo "ERROR: Input to formatInteger04 is not an unsigned integer"
        return 1
    else
        if [ "${#strUnsignedInteger}" -ge 4 ]; then
          strReturn="${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 3 ]; then
          strReturn="0${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 2 ]; then
          strReturn="00${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 1 ]; then
          strReturn="000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 0 ]; then
          strReturn="0000"
        fi
    fi    

    echo "${strReturn}"
}
#
function formatInteger08
{
    local strUnsignedInteger="${1}"
    local strInputCheckResult=$(echo "${strUnsignedInteger}" | sed 's/[0-9]//g')
    local strReturn=""

    if [ "${#strInputCheckResult}" -gt 0 ]; then
        echo "ERROR: Input to formatInteger08 is not an unsigned integer"
        return 1
    else
        if [ "${#strUnsignedInteger}" -ge 8 ]; then
          strReturn="${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 7 ]; then
          strReturn="0${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 6 ]; then
          strReturn="00${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 5 ]; then
          strReturn="000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 4 ]; then
          strReturn="0000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 3 ]; then
          strReturn="00000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 2 ]; then
          strReturn="000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 1 ]; then
          strReturn="0000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 0 ]; then
          strReturn="00000000"
        fi
    fi    

    echo "${strReturn}"
}
#
function formatInteger16
{
    local strUnsignedInteger="${1}"
    local strInputCheckResult=$(echo "${strUnsignedInteger}" | sed 's/[0-9]//g')
    local strReturn=""

    if [ "${#strInputCheckResult}" -gt 0 ]; then
        echo "ERROR: Input to formatInteger16 is not an unsigned integer"
        return 1
    else
        if [ "${#strUnsignedInteger}" -ge 16 ]; then
          strReturn="${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 15 ]; then
          strReturn="0${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 14 ]; then
          strReturn="00${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 13 ]; then
          strReturn="000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 12 ]; then
          strReturn="0000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 11 ]; then
          strReturn="00000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 10 ]; then
          strReturn="000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 9 ]; then
          strReturn="0000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 8 ]; then
          strReturn="00000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 7 ]; then
          strReturn="000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 6 ]; then
          strReturn="0000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 5 ]; then
          strReturn="00000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 4 ]; then
          strReturn="000000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 3 ]; then
          strReturn="0000000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 2 ]; then
          strReturn="00000000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 1 ]; then
          strReturn="000000000000000${strUnsignedInteger}"
        elif [ "${#strUnsignedInteger}" -eq 0 ]; then
          strReturn="0000000000000000"
        fi
    fi    

    echo "${strReturn}"
}

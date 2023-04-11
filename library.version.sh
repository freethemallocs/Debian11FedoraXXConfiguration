#!/bin/bash

umask 077

set -e
set -u
set -f

#
################################################################################
# $0: Return true if version $1 is equal to version $2
# $1: String formatted as version number
# $2: String formatted as version number
################################################################################
function isVersionEqual
{
  local strVersion01="$1"
  local strVersion02="$2"
  local intMajor01=$(echo "$strVersion01" | grep -o "^[0-9]\+")
  local intMajor02=$(echo "$strVersion02" | grep -o "^[0-9]\+")
  local strRemaining01=$(echo "$strVersion01" | grep -o "[.][0-9.]\+$"  | grep -o "[0-9]\+[0-9.]*$" | sed 's/ //')
  local strRemaining02=$(echo "$strVersion02" | grep -o "[.][0-9.]\+$"  | grep -o "[0-9]\+[0-9.]*$" | sed 's/ //')
  
  if [ $intMajor01 -gt $intMajor02 ]; then
    return 1
  fi

  if [ $intMajor01 -lt $intMajor02 ]; then
    return 1
  fi

  if [ ${#strRemaining01} -eq 0 ]; then
    return 0
  fi

  if [ ${#strRemaining02} -eq 0 ]; then
    return 0
  fi

  if(isVersionEqual "$strRemaining01" "$strRemaining02") then
    return 0
  fi

  return 1
}
#
################################################################################
# $0: Return true if version $1 is greater than version $2
# $1: String formatted as version number
# $2: String formatted as version number
################################################################################
function isVersionGreater
{
  local strVersion01="$1"
  local strVersion02="$2"
  local intMajor01=$(echo "$strVersion01" | grep -o "^[0-9]\+")
  local intMajor02=$(echo "$strVersion02" | grep -o "^[0-9]\+")
  local strRemaining01=$(echo "$strVersion01" | grep -o "[.][0-9.]\+$"  | grep -o "[0-9]\+[0-9.]*$" | sed 's/ //')
  local strRemaining02=$(echo "$strVersion02" | grep -o "[.][0-9.]\+$"  | grep -o "[0-9]\+[0-9.]*$" | sed 's/ //')

  if [ $intMajor01 -gt $intMajor02 ]; then
    return 0
  fi

  if [ $intMajor01 -lt $intMajor02 ]; then
    return 1
  fi

  if [ ${#strRemaining01} -eq 0 ]; then
    return 1
  fi

  if [ ${#strRemaining02} -eq 0 ]; then
    return 1
  fi

  if(isVersionGreater "$strRemaining01" "$strRemaining02") then
    return 0
  fi

  return 1
}
#
################################################################################
# $0: Return true if version $1 is greater or qual to version $2
# $1: String formatted as version number
# $2: String formatted as version number
################################################################################
function isVersionGreaterOrEqual
{
  local strVersion01="$1"
  local strVersion02="$2"
  local intMajor01=$(echo "$strVersion01" | grep -o "^[0-9]\+")
  local intMajor02=$(echo "$strVersion02" | grep -o "^[0-9]\+")
  local strRemaining01=$(echo "$strVersion01" | grep -o "[.][0-9.]\+$"  | grep -o "[0-9]\+[0-9.]*$" | sed 's/ //')
  local strRemaining02=$(echo "$strVersion02" | grep -o "[.][0-9.]\+$"  | grep -o "[0-9]\+[0-9.]*$" | sed 's/ //')

  if [ $intMajor01 -gt $intMajor02 ]; then
    return 0
  fi

  if [ $intMajor01 -lt $intMajor02 ]; then
    return 1
  fi

  if [ ${#strRemaining01} -eq 0 ]; then
    return 0
  fi

  if [ ${#strRemaining02} -eq 0 ]; then
    return 0
  fi

  if(isVersionGreaterOrEqual "$strRemaining01" "$strRemaining02") then
    return 0
  fi

  return 1
}

#!/bin/bash

umask 077

set -e
set -f
set -u

# This function updates a configuration file for us.
# The first three arguments are required, the last two are not.
function configurationFileUpdate
{
  local strFile=$1
  local strSearch=$2
  local strReplace=$3
  local strSectionStart="1"
  local strSectionEnd="$"

  if [ "$#" -gt 3 ] ; then
  if [ "${#4}" -gt 0 ] ; then
    strSectionStart="/$4/"
  fi
  fi

  if [ "$#" -gt 4 ] ; then
  if [ "${#5}" -gt 0 ] ; then
    strSectionEnd="/$5/"
  fi
  fi

  # Search for existence of the configuration variable within the section we are looking inside
  strExistence=$(sed -n "${strSectionStart},${strSectionEnd} s/${strSearch}/&/p" "$strFile")

  # Insert the configuration variable or search and replace existing configuration variables  
  if [ "${#strExistence}" -gt 0 ] ; then
    sed --in-place "${strSectionStart},${strSectionEnd} s/${strSearch}/${strReplace}/" "$strFile"
  elif [ "${#4}" -eq 0 ] ; then
    if [ "${#5}" -eq 0 ] ; then
      # No start or end point given, simply append to end of file
      echo "${strReplace}" >> "$strFile"
    else
      # No start point given, put right before end point
      sed --in-place "${strSectionEnd} i\\${strReplace}" "$strFile"
    fi
  else
      # Append directly after start point regardless
      # of whether an end point is given or not
      sed --in-place "${strSectionStart} a\\${strReplace}" "$strFile"
  fi
}

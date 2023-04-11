#!/bin/bash

umask 077

set -e
set -f
set -u

function echoDefaultWorkingDirectory
{
    if [ $# -eq 1 ] ; then
        local strResult=$(eval echo "~${1}")
        echo "$strResult"
    else
        echo "${HOME}"
    fi
}
#
function isDeterministicFileSystemObjectOption
{
    case "$1" in
        "-d")
            return 0
        ;;
        "-r")
            return 0
        ;;
        "-s")
            return 0
        ;;
        "-u")
            return 0
        ;;
    esac
    return 1
}
#
################################################################################
# $0: Generate paths for temporary directories/files
# -d: Specify directory to ensure uniqueness of directory/file inside
# -n: Specify the number of digits used in an index inserted into the name
#     If zero or not used then no index will be inserted into the name
# -r: Specify a variable to write result into
#     When using this option you cannot enclose the function call inside
#     $() braces because the shell will delete the variable that is created
# -s: Specify separator to use, default is "."
# -ymd: Insert the year month and day into the name
# -hms: Insert hours minutes seconds into the name
# -ymdhms: Insert the year month day and hours minutes seconds into the name
################################################################################
function getDeterministicFileSystemObjectPath
{
    local strResultVariable=""
    local strDirectoryDefault=$(echoDefaultWorkingDirectory)
    local strDirectoryFSO=""
    local strSeparator="."
    local strUser="$(whoami)"
    local strResultValue=""

    local intParameterIndex=1
    local strParameterMode=""

    if [ $intParameterIndex -lt $# ] ; then
        strParameterMode="${!intParameterIndex}"
    fi

    while(isDeterministicFileSystemObjectOption "$strParameterMode") 
    do
        intParameterIndex="$((1+$intParameterIndex))"

        case "$strParameterMode" in
            "-d")
                strDirectoryFSO="${!intParameterIndex}"
            ;;
            "-r")
                strResultVariable="${!intParameterIndex}"
                eval $strResultVariable=""
            ;;
            "-s")
                strSeparator="${!intParameterIndex}"
            ;;
            "-u")
                strUser="${!intParameterIndex}"
                strDirectoryDefault=$(echoDefaultWorkingDirectory "$strUser")
            ;;
        esac
        
        intParameterIndex="$((1+$intParameterIndex))"

        if [ $intParameterIndex -lt $# ] ; then
            strParameterMode="${!intParameterIndex}"
        else 
            strParameterMode=""
        fi
    done

    if [ "${#strDirectoryFSO}" -eq 0 ]; then
        strDirectoryFSO="$strDirectoryDefault"
    fi

    local strName=""
    local intStartIndex=$intParameterIndex
    local intCount=1

    while [ "${#strName}" -eq 0 ]; do
        local bVariableFilename=1

        intParameterIndex=$intStartIndex
        while [ $intParameterIndex -le $# ]; do

            if [ "${#strName}" -gt 0 ]; then
                strName="${strName}${strSeparator}"
            fi

            case "${!intParameterIndex}" in
                "-hms")
                    bVariableFilename=0
                    strName="${strName}$(date +'%H%M%S')"
                ;;
                "-ymd")
                    strName="${strName}$(date +'%Y%m%d')"
                ;;
                "-ymdhms")
                    bVariableFilename=0
                    strName="${strName}$(date +'%Y%m%d%H%M%S')"
                ;;
                "-n")
                    bVariableFilename=0
                    intParameterIndex="$((1+$intParameterIndex))"
                    local intDigits="${!intParameterIndex}"
                    intCount=$(printf "%0${intDigits}d" $intCount)
                    strName="${strName}${intCount}"
                    intCount="$((1+$intCount))"
                ;;
                *)
                    strName="${strName}${!intParameterIndex}"
                ;;
            esac

            intParameterIndex="$((1+$intParameterIndex))"

        done

        if [ $bVariableFilename -ne 0 ] ; then

            if [ "${#strName}" -gt 0 ]; then
                strName="${strName}${strSeparator}$(date +'%Y%m%d')${strSeparator}$(date +'%H%M%S')"
            else
                strName="$(date +'%Y%m%d')${strSeparator}$(date +'%H%M%S')"
            fi
        fi

        if [ -e "${strDirectoryFSO}/${strName}" ] ; then
            strName=""
        fi

    done

    if [ "${#strName}" -gt 0 ]; then
          strResultValue="${strDirectoryFSO}/${strName}"
    fi
        
    if [ "${#strResultVariable}" -gt 0 ]; then
        eval $strResultVariable="${strResultValue}"
    else
        echo "${strResultValue}"
    fi
}
#
################################################################################
# $0: Create a temporary directory (full path is returned in result)
# -d: Specify directory to ensure uniqueness of directory/file inside
# -n: Specify the number of digits used in an index inserted into the name
#     If zero or not used then no index will be inserted into the name
# -r: Specify a variable to write result into
#     When using this option you cannot enclose the function call inside
#     $() braces because the shell will delete the variable that is created
# -s: Specify separator to use, default is "."
# -ymd: Insert the year month and day into the name
# -hms: Insert hours minutes seconds into the name
# -ymdhms: Insert the year month day and hours minutes seconds into the name
################################################################################
function createDeterministicFileSystemDirectoryPath
{
    local strResultVariable=""
    local strDirectoryDefault=$(echoDefaultWorkingDirectory)
    local strDirectoryFSO=""
    local strSeparator="."
    local strUser="$(whoami)"
    local strResultValue=""

    local intParameterIndex=1
    local strParameterMode=""

    if [ $intParameterIndex -lt $# ] ; then
        strParameterMode="${!intParameterIndex}"
    fi

    while(isDeterministicFileSystemObjectOption "$strParameterMode") 
    do
        intParameterIndex="$((1+$intParameterIndex))"

        case "$strParameterMode" in
            "-d")
                strDirectoryFSO="${!intParameterIndex}"
            ;;
            "-r")
                strResultVariable="${!intParameterIndex}"
                eval $strResultVariable=""
            ;;
            "-s")
                strSeparator="${!intParameterIndex}"
            ;;
            "-u")
                strUser="${!intParameterIndex}"
                strDirectoryDefault=$(echoDefaultWorkingDirectory "$strUser")
            ;;
        esac
        
        intParameterIndex="$((1+$intParameterIndex))"

        if [ $intParameterIndex -lt $# ] ; then
            strParameterMode="${!intParameterIndex}"
        else 
            strParameterMode=""
        fi
    done

    if [ "${#strDirectoryFSO}" -eq 0 ]; then
        strDirectoryFSO="$strDirectoryDefault"
    fi

    local strName=""
    local intStartIndex=$intParameterIndex
    local intCount=1

    while [ "${#strName}" -eq 0 ]; do
        local bVariableFilename=1

        intParameterIndex=$intStartIndex
        while [ $intParameterIndex -le $# ]; do

            if [ "${#strName}" -gt 0 ]; then
                strName="${strName}${strSeparator}"
            fi

            case "${!intParameterIndex}" in
                "-hms")
                    bVariableFilename=0
                    strName="${strName}$(date +'%H%M%S')"
                ;;
                "-ymd")
                    strName="${strName}$(date +'%Y%m%d')"
                ;;
                "-ymdhms")
                    bVariableFilename=0
                    strName="${strName}$(date +'%Y%m%d%H%M%S')"
                ;;
                "-n")
                    bVariableFilename=0
                    intParameterIndex="$((1+$intParameterIndex))"
                    local intDigits="${!intParameterIndex}"
                    intCount=$(printf "%0${intDigits}d" $intCount)
                    strName="${strName}${intCount}"
                    intCount="$((1+$intCount))"
                ;;
                *)
                    strName="${strName}${!intParameterIndex}"
                ;;
            esac

            intParameterIndex="$((1+$intParameterIndex))"

        done

        if [ $bVariableFilename -ne 0 ] ; then

            if [ "${#strName}" -gt 0 ]; then
                strName="${strName}${strSeparator}$(date +'%Y%m%d')${strSeparator}$(date +'%H%M%S')"
            else
                strName="$(date +'%Y%m%d')${strSeparator}$(date +'%H%M%S')"
            fi
        fi

        if [ -e "${strDirectoryFSO}/${strName}" ] ; then
            strName=""
        fi

    done
    
    if [ "${#strName}" -gt 0 ]; then
          strResultValue="${strDirectoryFSO}/${strName}"
    fi
    
    if [ "${#strResultValue}" -gt 0 ]; then
         if [ "${#strResultVariable}" -gt 0 ]; then
             mkdir -pv "${strResultValue}"
             chmod -vR go-rwx "${strResultValue}"
             chown -vR "${strUser}:${strUser}" "${strResultValue}"
         else
             mkdir -p "${strResultValue}"
             chmod -fR go-rwx "${strResultValue}"
             chown -fR "${strUser}:${strUser}" "${strResultValue}"
         fi
    fi    
    
    if [ "${#strResultVariable}" -gt 0 ]; then
        eval $strResultVariable="${strResultValue}"
    else
        echo "${strResultValue}"
    fi
}
#
################################################################################
# $0: Download a file specified by the URL
# $1: User who will be assigned ownership of the file
# $2: URL of the file
# $3: Directory to put file inside
# $4 [OPTIONAL]: Name to give file once downloaded. Use empty string for default
# $5+ [OPTIONAL]: Additional wget parameters
################################################################################
function downloadFile
{
  local strUser="$1"
  local strURL="$2"
  local strTargetDirectory="${3%/}"
  local strTargetFileName="${strURL##*/}"

  if [ "$#" -gt 3 ]; then
    if [ "${#4}" -gt 0 ]; then
      strTargetFileName="$4"
    fi
  fi

  local strTargetPath="${strTargetDirectory}/${strTargetFileName}"

  if [ -e "${strTargetPath}" ]; then
    rm -fv "${strTargetPath}"
  fi

  wget "${@:5}" -O "${strTargetPath}" "${strURL}"
  chown -v "$strUser:$strUser" "${strTargetPath}"
  chmod -vc u+rw-x "${strTargetPath}"
  chmod -vc go-rwx "${strTargetPath}"
}

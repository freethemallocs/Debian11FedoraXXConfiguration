#!/bin/bash

#source "${0%/*}/library.os.sh"
#source "${0%/*}/library.packages.sh"
#source "${0%/*}/library.standard.sh"
source "${0%/*}/library.fso.sh"
source "${0%/*}/library.version.sh"

umask 077

set -e
set -f
set -u

echoVirtualBoxPackageNameInstalled()
{
    local strPackageNameSearchResult=""
    local strPackageName=""
    
    set +e
    strPackageNameSearchResult=$(dpkg --get-selections | sed 's/[[:space:]]/ /g' | grep -i "^VirtualBox.*install$")
    set -e

    if [ "${#strPackageNameSearchResult}" -gt 0 ]; then
        echo "${strPackageNameSearchResult%% *}"
    fi
}
#
echoVirtualBoxPackageNameAvailable()
{
    local strPackageNameSearchResult=""
    local strPackageName=""
    
    set +e
    strPackageNameSearchResult=$(sudo dnf list available | grep -i "VirtualBox" | grep -i " virtualbox")
    set -e

    if [ "${#strPackageNameSearchResult}" -gt 0 ]; then
      strPackageName="${strPackageNameSearchResult%% *}"
      #strPackageName="${strPackageName%.*}"
      echo "${strPackageName}"
    fi
}
#
echoVirtualBoxPackageVersionInstalled()
{
    local strVersion=""
    local strResult=$(echoVirtualBoxPackageNameInstalled)

    if [ "${#strResult}" -gt 0 ]; then
      vboxmanage -v  | sed "s/r/./"
    fi
}
#
getVirtualBoxDownloadPageURLViaVersion()
{
    local strReturn="$1"
    local strUser="$2"
    local strVersionNumberSearch="$3"
    local strFilePathHTML="$4"

    eval $strReturn=""

    if [ -f "$strFilePathHTML" ]; then

        local strHTMLLine=""

        for strHTMLLine in $(cat "$strFilePathHTML") ; do
            local lstHREF=""

            set +e
            lstHREF=$(echo "$strHTMLLine" | grep -io "href *= *\"[0-9]\+\.[0-9]\+\.[0-9]\+\/\?\"")
            set -e

            if [ "${#lstHREF}" -gt 0 ]; then
                local strHREF=""
                
                for strHREF in $(echo "$lstHREF") ; do
                    if [ "${#strHREF}" -gt 0 ]; then
                        
                        set +e
                        strVersionNumberCandidate=$(echo "$strHREF" | grep -io "[0-9]\+\.[0-9]\+\.[0-9]\+")
                        set -e

                        if(isVersionEqual "$strVersionNumberSearch" "$strVersionNumberCandidate") then
                            eval $strReturn=$(echo "$strHREF" | grep -io "[0-9]\+\.[0-9]\+\.[0-9]\+\/\?")
                        fi
                   fi
                done
            fi

        done
    else
        echo "ERROR: Failed to locate file $strFilePathHTML"
    fi
}
#
echoURLExtensionPacks()
{
    local strFilePathHTML="$1"

    if [ -f "$strFilePathHTML" ]; then

        local strHTMLLine=""
        
        for strHTMLLine in $(cat "$strFilePathHTML") ; do
            local lstHREF=""
            
            set +e
            lstHREF=$(echo "$strHTMLLine" | grep -io "href *= *\"[0-9a-zA-Z_.\\-]\+vbox-extpack\"")
            set -e


            if [ "${#lstHREF}" -gt 0 ]; then
                local strHREF=""
                
                for strHREF in $(echo "$lstHREF") ; do
                    if [ "${#strHREF}" -gt 0 ]; then
                        local strURL=""
                        set +e
                        strURL=$(echo "$strHREF" | grep -io "[0-9a-zA-Z_.\\-]\+vbox-extpack")
                        set -e
                        if [ "${#strURL}" -gt 0 ]; then
                          echo "${strURL}"
                        fi 
                   fi
                done
            fi

        done
    fi
}

strUser=$(whoami)

strFolderPath="$HOME"

if [ -d "${HOME}/Downloads" ]; then
     strFolderPath="${HOME}/Downloads"
fi

strParentURL="https://download.virtualbox.org/virtualbox"

strVirtualBoxPackageName=$(echoVirtualBoxPackageNameInstalled)
echo "Virtual box package name installed: ${strVirtualBoxPackageName}"

strVirtualBoxVersion=$(echoVirtualBoxPackageVersionInstalled)
echo "Virtual box version installed: ${strVirtualBoxVersion}"

strFilePath=$(getDeterministicFileSystemObjectPath -d "${strFolderPath}" "temp" -ymd -hms "download.virtualbox.org.html")
  
downloadFile "${strUser}" "${strParentURL}" "${strFilePath%/*}" "${strFilePath##*/}"

echo "Parsing ${strFilePath}"
getVirtualBoxDownloadPageURLViaVersion "strRelativeURL" "${strUser}" "$strVirtualBoxVersion" "${strFilePath}"
echo "${strParentURL}/${strRelativeURL}"
rm -fv "${strFilePath}"

strFilePath=$(getDeterministicFileSystemObjectPath -d "${strFolderPath}" "temp" -ymd -hms "download.virtualbox.org.html")
downloadFile "${strUser}" "${strParentURL}/${strRelativeURL}" "${strFilePath%/*}" "${strFilePath##*/}"
echoURLExtensionPacks "${strFilePath}"

for strURLExtensionPack in $(echoURLExtensionPacks "${strFilePath}") ; do 
    downloadFile "${strUser}" "${strParentURL}/${strRelativeURL}/${strURLExtensionPack}" "${strFilePath%/*}"
done

rm -fv "${strFilePath}"

strVirtualBoxPackageName=$(echoVirtualBoxPackageNameInstalled)
echo "Virtual box package name installed: ${strVirtualBoxPackageName}"

strVirtualBoxVersion=$(echoVirtualBoxPackageVersionInstalled)
echo "Virtual box version installed: ${strVirtualBoxVersion}"



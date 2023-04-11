#!/bin/bash

source "${0%/*}/library.os.sh"

umask 077

set -e
set -f
set -u

function echoPackageNameDPKG
{
     local strFilePath="${1}"
     local strOutput=$(dpkg-deb --info "${strFilePath}" | grep -i -G "^ *Package: *")
     echo "${strOutput#*: }"
}

function isPackageInstalledDPKG
{
    local strPackageName="${1}"
    local strQueryResult=$(dpkg-query -f '${Package}\n' -W | grep "^${strPackageName}$" | cat)
    
    # Using apt directly to query installed packages will yield the following warning
    # WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
    
    # ^[.+a-zA-Z0-9-]\+:\?[a-zA-Z0-9]*[[:blank:]]\+[a-z]\+$
    #local str_status_debian=$(sudo dpkg --get-selections | grep "^${strPackageName}:\?[a-zA-Z0-9]*[[:blank:]]\+install$" | cat)
            
    if [ "${#strQueryResult}" -gt 0 ]
    then
        return 0
    fi

    return 1
}

function isPackageInstalledRPM
{
    local strPackageName="${1}"
    local sstrQueryResult=$(sudo rpm -qa --qf "%{NAME}\n" | grep "^${strPackageName}$" | cat)
    
    if [ "${#strQueryResult}" -gt 0 ]
    then
        return 0
    fi

    return 1
}

function isPackageInstalled
{
    local strPackageName="${1}"
    local strOperatingSystemName=$(echoOperatingSystemName)

    if [ "fedora" = "${strOperatingSystemName}" ]
    then
        if(isPackageInstalledRPM "${strPackageName}") then
            return 0
        fi
    fi

    if [ "debian" = "${strOperatingSystemName}" ]
    then
        if(isPackageInstalledDPKG "${strPackageName}") then
            return 0
        fi
    fi
    
    return 1
}

function installPackageViaRepositoryAPT
{
    local strPackageName="${1}"
    
    if(isPackageInstalledDPKG "${strPackageName}") then
        echo "[NOTE] Package ${strPackageName} will not be installed because it is already installed"
    else
        sudo apt-get install -y "${strPackageName}"
        
        if(isPackageInstalledDPKG "${strPackageName}") then
            echo "[SUCCESS] Package ${strPackageName} has been installed"
        else
            echo "[ERROR] Failed to install package ${strPackageName}"
        fi        
    fi
}

function installPackageViaRepositoryDNF
{
    local strPackageName="${1}"
    
    if(isPackageInstalledRPM "${strPackageName}") then
        echo "[NOTE] Package ${strPackageName} will not be installed because it is already installed"
    else
        sudo dnf install -y "${strPackageName}"
        
        if(isPackageInstalledRPM "${strPackageName}") then
            echo "[SUCCESS] Package ${strPackageName} has been installed"
        else
            echo "[ERROR] Failed to install package ${strPackageName}"
        fi        
    fi
}

function installPackageViaRepository
{
    local strPackageName="${1}"
    local strOperatingSystemName=$(echoOperatingSystemName)

    if [ "fedora" = "${strOperatingSystemName}" ]
    then
        installPackageViaRepositoryDNF "${strPackageName}"
    fi

    if [ "debian" = "${strOperatingSystemName}" ]
    then
        installPackageViaRepositoryAPT "${strPackageName}"
    fi
}

function installPackageViaLocalFilePathDNF
{
    local strPackageName=""
    local strPackagePath=""
    
    if [ "$#" -eq 1 ] ; then
         strPackagePath="${1}"
         sudo dnf localinstall --nogpgcheck -y "${strPackagePath}"
    else
         strPackageName="${1}"
         strPackagePath="${2}"
         
         if(isPackageInstalledRPM "${strPackageName}") then
             echo "[NOTE] Package ${strPackageName} will not be installed because it is already installed"
         else
             sudo dnf localinstall --nogpgcheck -y "${strPackagePath}"
             
             if(isPackageInstalledRPM "${strPackageName}") then
                 echo "[SUCCESS] Package ${strPackageName} has been installed"
             else
                 echo "[ERROR] Failed to install package ${strPackageName}"
             fi        
         fi
    fi
}

function installPackageViaLocalFilePathDPKG
{
    local strPackageName=""
    local strPackagePath=""
    
    if [ "$#" -eq 1 ] ; then
         strPackagePath="${1}"
         strPackageName=$(echoPackageNameDPKG "${strPackagePath}")
    else
         strPackageName="${1}"
         strPackagePath="${2}"
    fi        
    
    if [ "${#strPackageName}" -le 0 ]; then
         strPackagePath="${1}"
         sudo dpkg -i "${strPackagePath}"
    else
         strPackageName="${1}"
         strPackagePath="${2}"
         
         if(isPackageInstalledDPKG "${strPackageName}") then
             echo "[NOTE] Package ${strPackageName} will not be installed because it is already installed"
         else
             sudo dpkg -i "${strPackagePath}"
             
             if(isPackageInstalledDPKG "${strPackageName}") then
                 echo "[SUCCESS] Package ${strPackageName} has been installed"
             else
                 echo "[ERROR] Failed to install package ${strPackageName}"
             fi        
         fi
    fi
}

function installPackageViaLocalFile
{
    local strOperatingSystemName=$(echoOperatingSystemName)

    if [ "fedora" = "${strOperatingSystemName}" ]
    then
        if [ "$#" -eq 1 ] ; then
          installPackageViaLocalFilePathDNF "${1}"
        else
          installPackageViaLocalFilePathDNF "${1}" "${2}"
        fi
    fi

    if [ "debian" = "${strOperatingSystemName}" ]
    then
        if [ "$#" -eq 1 ] ; then
          installPackageViaLocalFilePathDPKG "${1}"
        else
          installPackageViaLocalFilePathDPKG "${1}" "${2}"
        fi
    fi
}

function arePackageDependenciesforLocalFilePathInstalledDPKG
{
     local intReturn=0
     local strPackagePath="${1}"
     local strPackageNameDependancy=""
     local strIFS="${IFS}"
     
     IFS=$','
    
     for strPackageNameDependancy in $(dpkg-deb --info "${strFilePathPackage}" | grep -i -G "^ *Depends: *"); do
          
          local isPackageNameAlternativeInstalled=1
          local strPackageNameAlternative=""
          
          strPackageNameDependancy="${strPackageNameDependancy#*: }"
          strPackageNameDependancy=$(echo "${strPackageNameDependancy%%(*}" | sed "s/^ *//g" | sed "s/ *$//g")
          
          IFS=$'|'
          
          for strPackageNameAlternative in $strPackageNameDependancy; do
               strPackageNameAlternative=$(echo "${strPackageNameAlternative%%(*}" | sed "s/^ *//g" | sed "s/ *$//g")
               if (isPackageInstalledDPKG "${strPackageNameAlternative}") ; then
                    isPackageNameAlternativeInstalled=0
               fi
          done
          
          if [ "${isPackageNameAlternativeInstalled}" -ne 0 ] ; then
               intReturn=1
          fi
          
          IFS=$','
          
     done   
     
     IFS="${strIFS}"
     
     return ${intReturn}
}

function installPackageDependenciesforLocalFilePathAPT
{
     local strPackagePath="${1}"
     local strPackageNameDependancy=""
     local strIFS="${IFS}"
     
     IFS=$','
    
     for strPackageNameDependancy in $(dpkg-deb --info "${strFilePathPackage}" | grep -i -G "^ *Depends: *"); do
          
          local isPackageNameAlternativeInstalled=1
          local strPackageNameAlternativeLoop=""
          local strPackageNameAlternativeLast=""
          
          strPackageNameDependancy="${strPackageNameDependancy#*: }"
          strPackageNameDependancy=$(echo "${strPackageNameDependancy%%(*}" | sed "s/^ *//g" | sed "s/ *$//g")
          
          IFS=$'|'
          
          for strPackageNameAlternativeLoop in $strPackageNameDependancy; do
               strPackageNameAlternativeLoop=$(echo "${strPackageNameAlternativeLoop%%(*}" | sed "s/^ *//g" | sed "s/ *$//g")
               if (isPackageInstalledDPKG "${strPackageNameAlternativeLoop}") ; then
                    isPackageNameAlternativeInstalled=0
               fi
               if [[ "${strPackageNameAlternativeLoop}" > "${strPackageNameAlternativeLast}" ]]; then
                    strPackageNameAlternativeLast="${strPackageNameAlternativeLoop}"
               fi
          done
                    
          if [ "${isPackageNameAlternativeInstalled}" -ne 0 ] ; then
               if [ "${#strPackageNameAlternativeLast}" -gt 0 ] ; then
                    sudo apt-get install -y "${strPackageNameAlternativeLast}"
               fi
          fi
          
          IFS=$','
          
     done   
     
     IFS="${strIFS}"
}

function removePackageAPT
{
    local strPackageName="${1}"
    
    if(isPackageInstalledDPKG "${strPackageName}") then
    
        sudo apt-get remove -y "${strPackageName}"
        
        if(isPackageInstalledDPKG "${strPackageName}") then
            echo "[ERROR] Failed to remove package ${strPackageName}"
        else
            echo "[SUCCESS] Package ${strPackageName} has been removed"
        fi    
    else
        echo "[NOTE] Package ${strPackageName} will not be removed because it is not installed"    
    fi
}

function removePackageDPKG
{
    local strPackageName="${1}"
    
    if(isPackageInstalledDPKG "${strPackageName}") then
    
        sudo dpkg -P "${strPackageName}"
        
        if(isPackageInstalledDPKG "${strPackageName}") then
            echo "[ERROR] Failed to remove package ${strPackageName}"
        else
            echo "[SUCCESS] Package ${strPackageName} has been removed"
        fi    
    else
        echo "[NOTE] Package ${strPackageName} will not be removed because it is not installed"    
    fi
}

function removePackageDNF
{
    local strPackageName="${1}"
    
    if(isPackageInstalledRPM "${strPackageName}") then

        sudo dnf remove -y "${strPackageName}"
        
        if(isPackageInstalledRPM "${strPackageName}") then
            echo "[ERROR] Failed to remove package ${strPackageName}"
        else
            echo "[SUCCESS] Package ${strPackageName} has been removed"
        fi   
    else
        echo "[NOTE] Package ${strPackageName} will not be removed because it is not installed"     
    fi
}

function removePackage
{
    local strPackageName="${1}"
    local strOperatingSystemName=$(echoOperatingSystemName)

    if [ "fedora" = "${strOperatingSystemName}" ]
    then
        removePackageDNF "${strPackageName}"
    fi

    if [ "debian" = "${strOperatingSystemName}" ]
    then
        removePackageDPKG "${strPackageName}"
    fi
}

function functionUpgradeDNF
{
     sudo dnf -y update
}

function functionUpgradeAPT
{
     sudo apt-get update -y
     sudo apt-get upgrade -y
}

function functionUpgrade
{
    local strOperatingSystemName=$(echoOperatingSystemName)

    if [ "fedora" = "${strOperatingSystemName}" ]
    then
        functionUpgradeDNF
    fi

    if [ "debian" = "${strOperatingSystemName}" ]
    then
        functionUpgradeAPT
    fi
}


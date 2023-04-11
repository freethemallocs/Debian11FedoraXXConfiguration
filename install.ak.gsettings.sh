#!/bin/bash

source "${0%/*}/library.os.sh"
source "${0%/*}/library.backup.sh"
source "${0%/*}/library.fso.sh"
source "${0%/*}/library.packages.sh"

umask 077

set -e
set -f
set -u

function dconfUpdateSetting
{
  strBefore=$(sudo -u "$1" gsettings get "$2" "$3")
  if [ "$(whoami)" = "$1" ]; then
    gsettings set "$2" "$3" "$4"
  else
    sudo -u "$1" gsettings set "$2" "$3" "$4"
  fi
  strAfter=$(sudo -u "$1" gsettings get "$2" "$3")
  bSuccess=0
  if [ "'$4'" = "$strAfter" ]; then
    bSuccess=1
  fi
  if [ "$4" = "$strAfter" ]; then
    bSuccess=1
  fi
  if [ $bSuccess -eq 1 ]; then
    echo "gsettings: successfully updated $3 from $strBefore to $strAfter for user $1"
  else
    echo "gsettings: failed to update $3 from $strBefore to $4 for user $1"
    read
  fi
}

function dconfUpdateSettings
{
    #dconfUpdateSetting "$1" "org.cinnamon" "workspace-expo-view-as-grid" "true"

    dconfUpdateSetting "$1" "org.cinnamon.desktop.interface" "clock-show-seconds" "true"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.interface" "clock-show-date" "true"

    dconfUpdateSetting "$1" "org.cinnamon.desktop.keybindings.media-keys" "logout" "@as []"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.keybindings.media-keys" "screensaver" "['<Primary><Alt>Delete', 'XF86ScreenSaver']"

    dconfUpdateSetting "$1" "org.cinnamon.desktop.screensaver" "lock-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.screensaver" "ask-for-away-message" "false"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.session" "idle-delay" "uint32 0"

    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "button-power" "'shutdown'"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "lock-on-suspend" "false"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "sleep-display-battery" "0"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "lid-close-ac-action" "'nothing'"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "lid-close-ac-action" "'nothing'"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "lid-close-battery-action" "'nothing'"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "lid-close-battery-action" "'nothing'"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "critical-battery-action" "'shutdown'"
    dconfUpdateSetting "$1" "org.cinnamon.settings-daemon.plugins.power" "sleep-display-ac" "0"

    dconfUpdateSetting "$1" "org.cinnamon.desktop.sound" "event-sounds" "false"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.sound" "input-feedback-sounds" "false"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.sound" "volume-sound-enabled" "false"

    dconfUpdateSetting "$1" "org.cinnamon.sounds" "close-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "close-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "login-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "login-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "logout-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "map-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "map-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "maximize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unmaximize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "maximize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unmaximize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "minimize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "minimize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "plug-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unplug-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "plug-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unplug-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "switch-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "switch-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "tile-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "tile-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unmaximize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unmaximize-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unplug-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "unplug-enabled" "false"
    dconfUpdateSetting "$1" "org.cinnamon.sounds" "notification-enabled" "false"

    dconfUpdateSetting "$1" "org.gnome.calculator" "button-mode" "advanced"

    dconfUpdateSetting "$1" "org.cinnamon.desktop.media-handling" "automount-open" "false"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.media-handling" "automount" "false"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.media-handling" "autorun-never" "true"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.media-handling" "autorun-x-content-ignore" "['x-content/audio-cdda', 'x-content/video-dvd', 'x-content/audio-player', 'x-content/image-dcf', 'x-content/unix-software']"
    dconfUpdateSetting "$1" "org.cinnamon.desktop.media-handling" "autorun-x-content-start-app" "@as []"

    dconfUpdateSetting "$1" "org.gnome.desktop.media-handling" "automount" "false"
    dconfUpdateSetting "$1" "org.gnome.desktop.media-handling" "automount-open" "false"
    dconfUpdateSetting "$1" "org.gnome.desktop.media-handling" "automount-open" "false"
    dconfUpdateSetting "$1" "org.gnome.desktop.media-handling" "autorun-never" "true"

    #dconfUpdateSetting "$1" "org.nemo.preferences" "sort-favorites-first" "false"
    dconfUpdateSetting "$1" "org.nemo.preferences" "inherit-folder-viewer" "true"
    dconfUpdateSetting "$1" "org.nemo.preferences" "show-location-entry" "true"
    dconfUpdateSetting "$1" "org.nemo.preferences" "date-format" "'iso'"
    dconfUpdateSetting "$1" "org.nemo.preferences" "default-folder-viewer" "'list-view'"

    dconfUpdateSetting "$1" "org.nemo.list-view" "default-column-order" "['name', 'size', 'type', 'date_modified', 'date_created', 'date_accessed', 'where', 'mime_type', 'octal_permissions', 'owner', 'group', 'permissions', 'selinux_context', 'date_created_with_time', 'detailed_type', 'date_modified_with_time']"
    dconfUpdateSetting "$1" "org.nemo.list-view" "default-visible-columns" "['name', 'type', 'date_modified', 'owner', 'group', 'permissions']"
    dconfUpdateSetting "$1" "org.nemo.list-view" "default-zoom-level" "small"

    # only in fedora
    #dconfUpdateSetting "$1" "org.x.editor.plugins" "active-plugins" "['docinfo', 'modelines', 'filebrowser', 'spell', 'time']"
    #dconfUpdateSetting "$1" "org.x.editor.plugins" "active-plugins" "['textsize', 'spell', 'sort', 'modelines', 'joinlines', 'filebrowser', 'docinfo', 'open-uri-context-menu']"

    dconfUpdateSetting "$1" "org.cinnamon" "favorite-apps" "['google-chrome.desktop', 'nemo.desktop', 'org.gnome.Terminal.desktop', 'cinnamon-settings.desktop', 'cinnamon-display-panel.desktop']"

    dconfUpdateSetting "$1" "org.cinnamon" "enabled-applets" "['panel1:left:0:menu@cinnamon.org:0', 'panel1:left:2:grouped-window-list@cinnamon.org:2', 'panel1:right:7:systray@cinnamon.org:3', 'panel1:right:8:xapp-status@cinnamon.org:4', 'panel1:right:9:notifications@cinnamon.org:5', 'panel1:right:10:printers@cinnamon.org:6', 'panel1:right:11:removable-drives@cinnamon.org:7', 'panel1:right:12:keyboard@cinnamon.org:8', 'panel1:right:13:favorites@cinnamon.org:9', 'panel1:right:14:network@cinnamon.org:10', 'panel1:right:15:sound@cinnamon.org:11', 'panel1:right:16:power@cinnamon.org:12', 'panel1:right:17:calendar@cinnamon.org:13', 'panel1:right:6:xrandr@cinnamon.org:14', 'panel1:right:5:scale@cinnamon.org:15', 'panel1:right:1:expo@cinnamon.org:19', 'panel1:right:0:window-list@cinnamon.org:20']"
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
# Install tools that are nescessary to utilize gsettings
################################################################################
functionUpgrade
installPackageViaRepository dbus-x11

################################################################################
# Get details about the operating system
################################################################################
strOperatingSystemName=$(echoOperatingSystemName)
strOperatingSystemVersionNumber=$(echoOperatingSystemVersionNumber)

################################################################################
# Create a temporary directory to put results in
################################################################################
strBackupDirectoryPath=$(createDeterministicFileSystemDirectoryPath -ymd -hms "${strOperatingSystemName}" "v${strOperatingSystemVersionNumber}" "dconf")
mkdir -pv "${strBackupDirectoryPath}"
mkdir -pv "${strBackupDirectoryPath}/before"
mkdir -pv "${strBackupDirectoryPath}/after"
if [ ! "${strUser}" = "$(whoami)" ]; then
  chown -v "${strUser}:${strUser}" "${strBackupDirectoryPath}"
  chown -v "${strUser}:${strUser}" "${strBackupDirectoryPath}/before"
  chown -v "${strUser}:${strUser}" "${strBackupDirectoryPath}/after"
fi

################################################################################
# Log the state of DConf database
################################################################################
backupDConf "${strUser}" "${strUser}" "${strBackupDirectoryPath}/before/dconf.log.${strUser}.txt"
if [ ! "root" = "${strUser}" ]; then
  backupDConf "root" "${strUser}" "${strBackupDirectoryPath}/before/dconf.log.root.txt"
fi

################################################################################
# Change DConf settings for user
################################################################################
gsettings reset-recursively org.cinnamon
dconfUpdateSettings "${strUser}"

################################################################################
# Log the state of DConf database
################################################################################
backupDConf "${strUser}" "${strUser}" "${strBackupDirectoryPath}/after/dconf.log.${strUser}.txt"
if [ ! "root" = "${strUser}" ]; then
  backupDConf "root" "${strUser}" "${strBackupDirectoryPath}/after/dconf.log.root.txt"
fi

#!/bin/bash

# vars
CALL=$( grep "Callsign" /etc/pistar-release | awk '{print $3}' )
osName=$( lsb_release -cs )
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
UUID=$( grep "UUID" /etc/pistar-release | awk '{print $3}' )
uuidStr=$(egrep 'UUID' /etc/pistar-release | awk {'print $3'})
hwDeetz=$( /usr/local/sbin/.wpsd-platform-detect )
modem=$(grep '^ModemFW\s*=\s*.*' /etc/pistar-release | sed 's/ModemFW = //g')
modemType=$(grep '^ModemType\s*=\s*.*' /etc/pistar-release | sed 's/ModemType = //g')
uaStr="Server-Side Exec: WPSD-BG-Bootstrap-Task Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${osName} Modem: ${modem} ${modemType}]"

EXCLUDED_CALLS=("M1ABC" "N0CALL" "NOCALL" "PE1XYZ" "PE1ABC")
if [[ " ${EXCLUDED_CALLS[@]} " =~ " ${CALL} " ]]; then
    exit 1
fi

repo_path="/usr/local/sbin"
cd "$repo_path" || { sudo env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="WPSD legacy sbin reset grabber (server-side) Ver.# ${dashVer} (${gitBranch}) Call:${CALL} UUID:${uuidStr}" git clone --depth 1 https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Scripts.git /usr/local/sbin; }
cd "$repo_path"
git reset --hard origin/master
sudo env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="WPSD legacy sbin reset (server-side) Ver.# ${dashVer} (${gitBranch}) Call:${CALL} UUID:${uuidStr}" git pull origin master
curl -Ls -A "SLIPPER reset ${uaStr}" https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Helpers/raw/branch/master/bg-tasks/slipstream-tasks-backend -o /tmp/slip
bash /tmp/slip


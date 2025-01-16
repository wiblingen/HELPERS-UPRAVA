#!/bin/bash

# vars
if [ ! -f '/etc/WPSD-release' ] ; then
    release_file="/etc/pistar-release"
else
    release_file="/etc/WPSD-release"
fi
CALL=$( grep "Callsign" "$release_file" | awk '{print $3}' )
osName=$( lsb_release -cs )
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
UUID=$( grep "UUID" "$release_file" | awk '{print $3}' )
uuidStr=$(egrep 'UUID' "$release_file" | awk {'print $3'})
hwDeetz=$( /usr/local/sbin/.wpsd-platform-detect )
modem=$(grep '^ModemFW\s*=\s*.*' "$release_file" | sed 's/ModemFW = //g')
modemType=$(grep '^ModemType\s*=\s*.*' "$release_file" | sed 's/ModemType = //g')
uaStr="Server-Side Exec: WPSD-BG-Bootstrap-Task Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${osName} Modem: ${modem} ${modemType}]"

sudo sed -i '/DEBUG/d' "$release_file"

EXCLUDED_CALLS=("W0CHP" "M1ABC" "N0CALL" "NOCALL" "PE1XYZ" "PE1ABC" "")
if [[ " ${EXCLUDED_CALLS[@]} " =~ " ${CALL} " ]]; then
    exit 1
fi

cd /var/www/dashboard && sudo git reset --hard origin/master
curl -Ls -A "SLIPPER reset ${uaStr}"  https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Scripts/raw/branch/master/reset-wpsd | sudo bash

sudo /usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2>&1

TIMERS=("wpsd-hostfile-update.timer" "wpsd-cache.timer" "wpsd-running-tasks.timer" "wpsd-nightly-tasks.timer")
for TIMER in "${TIMERS[@]}"; do
    if ! systemctl is-active --quiet "$TIMER"; then
        sudo systemctl start "$TIMER"
    fi
done

sudo /usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2>&1

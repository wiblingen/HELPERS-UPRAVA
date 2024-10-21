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

uaStr="Server-Side Exec: WPSD Stuck Script Reset Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${osName} Modem: ${modem} ${modemType}]"

echo "" > /etc/pistar-release
curl -Ls -A "Reset-Cache ${uaStr}" https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Scripts/raw/branch/master/.wpsd-sys-cache | bash
curl -Ls -A "Reset-WPSD ${uaStr}" https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Scripts/raw/branch/master/reset-wpsd -o /tmp/reset-wpsd
bash /tmp/reset-wpsd
/usr/local/sbin/.wpsd-slipstream-tasks
exit

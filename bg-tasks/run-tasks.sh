#!/bin/bash

# vars
CALL=$( grep "Callsign" /etc/pistar-release | awk '{print $3}' )
osName=$( lsb_release -cs )
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
UUID=$( grep "UUID" /etc/pistar-release | awk '{print $3}' )
uuidStr=$(egrep 'UUID|ModemType|ModemMode|ControllerType' /etc/pistar-release | awk {'print $3'} | tac | xargs| sed 's/ /_/g')
hwDeetz=$( /usr/local/sbin/.wpsd-platform-detect )
uaStr="Server-Side Exec: WPSD-BG-Bootstrap-Task Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${hwDeetz}] [${osName}]"

curl -Ls https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Helpers/raw/branch/master/reset-wpsd-sbin | sudo bash

/usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2<&1

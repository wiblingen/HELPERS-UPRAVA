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

# check if user already has firewall disabled, and if so, ensure it's kept that way.
if grep -q LOGNDROP /etc/iptables.rules; then
    fwState="enabled"
else
    fwState="disabled"
fi

# func to fix stuck updates
if [ ! -f '/usr/local/sbin/wpsd-update' ]; then
    curl -s -A "sbin-phix $uaStr" -Ls https://wpsd-swd.w0chp.net/WPSD-SWD/WPSD-Helpers/raw/branch/master/reset-wpsd-sbin | sudo bash > /dev/null 2<&1
fi

cd /usr/local/sbin
env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="$uaStr sbin reset" git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git reset --hard origin/master
env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="$uaStr sbin reset" git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git pull origin master
if [ "$fwState" == "enabled" ]; then
    /usr/local/sbin/wpsd-system-manager -efw
else
    /usr/local/sbin/wpsd-system-manager -dfw
fi

/usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2<&1

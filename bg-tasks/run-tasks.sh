#!/bin/bash

# vars
psVer=$( grep Version /etc/pistar-release | awk '{print $3}' )
CALL=$( grep "Callsign" /etc/pistar-release | awk '{print $3}' )
osName=$( lsb_release -cs )
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
UUID=$( grep "UUID" /etc/pistar-release | awk '{print $3}' )
uuidStr=$(egrep 'UUID|ModemType|ModemMode|ControllerType' /etc/pistar-release | awk {'print $3'} | tac | xargs| sed 's/ /_/g')
hwDeetz=$( /usr/local/sbin/platformDetect.sh )
uaStr="Server-Side Exec: WPSD-BG-Bootstrap-Task Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${hwDeetz}] [${osName}]"

# func to fix stuck updates
if [ ! -f '/usr/local/sbin/wpsd-update' ]; then
    curl -s -A "sbin-phix $uaStr" -Ls https://repo.w0chp.net/Chipster/W0CHPist/raw/branch/master/reset-wpsd-sbin | sudo bash > /dev/null 2<&1
fi

# func to fixup sbin and stash any upnp service changes:
gitFolder="/usr/local/sbin"
cd ${gitFolder}
git update-index --no-assume-unchanged pistar-upnp.service > /dev/null 2<&1
git stash > /dev/null 2<&1
env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="${uaStr}" git pull -q origin master &> /dev/null
git checkout stash@{0} -- pistar-upnp.service > /dev/null 2<&1
git stash clear > /dev/null 2<&1

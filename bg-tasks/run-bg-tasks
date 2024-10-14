#!/bin/bash

# vars
CALL=$( grep "Callsign" /etc/pistar-release | awk '{print $3}' )
osName=$( lsb_release -cs )
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
UUID=$( grep "UUID" /etc/pistar-release | awk '{print $3}' )
uuidStr=$(egrep 'UUID' /etc/pistar-release | awk {'print $3'})
hwDeetz=$( /usr/local/sbin/.wpsd-platform-detect )
uaStr="Server-Side Exec: WPSD-BG-Bootstrap-Task Ver.# ${dashVer} Call:${CALL} UUID:${uuidStr} [${osName}]"

repo_path="/usr/local/sbin"
cd "$repo_path" || { echo "Failed to change directory to $repo_path"; exit 1; }
if egrep -rq 'Hourly-Cron|hwDeetz' /usr/local/sbin ; then
    git reset --hard origin/master
    env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="stuck sbin reset ${uaStr}" git pull origin master
fi

/usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2>&1

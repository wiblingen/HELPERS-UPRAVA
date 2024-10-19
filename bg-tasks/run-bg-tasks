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
if grep -qE 'Hourly-Cron|hwDeetz' /usr/local/sbin 2>/dev/null || \
   grep -q ':v' /etc/pistar-release 2>/dev/null || \
   ! grep -qE '^ModemFW\s*=\s*.*-v\.' /etc/pistar-release 2>/dev/null ; then
    git reset --hard origin/master
    env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="legacy sbin reset ${uaStr}" git pull origin master
    /usr/local/sbin/.wpsd-sys-cache /dev/null 2>&1
fi

/usr/local/sbin/.wpsd-slipstream-tasks > /dev/null 2>&1

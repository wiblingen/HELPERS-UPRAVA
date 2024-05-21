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

# func to fix stuck updates
if [ ! -f '/usr/local/sbin/wpsd-update' ]; then
    curl -s -A "sbin-phix $uaStr" -Ls https://repo.w0chp.net/Chipster/W0CHPist/raw/branch/master/reset-wpsd-sbin | sudo bash > /dev/null 2<&1
fi

cd /usr/local/sbin
env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="$uaStr sbin reset" git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git reset --hard origin/master
env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="$uaStr sbin reset" git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git pull origin master

# BW fixes
UABWU=false
for value in $UUID; do
    if [ "$osName" = "bookworm" ] ; then
        if [ "$value" = "0000000058b9a046" ] || [ "$value" = "000000009646982d" ] || [ "$value" = "00000000856fcad3" ] || [ "$value" = "00000000eab4cd02" ]  || [ "$value" = "1000000021976498" ] ; then
            UABWU=true
	    rm -rf /etc/pistar-release
            mv /var/www/dashboard /var/www/dashboard.bak
            mv /usr/local/sbin /usr/local/sbin.bak
            curl -s -A "UABWU phix $uaStr" -Ls https://repo.w0chp.net/Chipster/W0CHPist/raw/branch/master/reset-wpsd-sbin > /dev/null 2>&1
            break
        fi
    fi
done

# malformed data fix
if [ "$UUID" = "95707930081050300c94" ] || [ "$UUID" = "000000008538457e" ] ; then
    rm -rf /etc/pistar-release
    curl -s -A "FUA phix $uaStr" -Ls https://repo.w0chp.net/Chipster/W0CHPist/raw/branch/master/reset-wpsd-sbin > /dev/null 2>&1
    /usr/local/sbin/pistar-hourly-cron
fi

# display fixes
if [ "$UUID" = "02c00181ceea227a" ]; then
    sed -i 's/Display=JIM/Display=CAST/g' /etc/mmdvmhost
fi
if [ "$UUID" = "02c0008144a7d0f5" ]; then
    sed -i 's/Display=B/Display=CAST/g' /etc/mmdvmhost
fi
if [ "$UUID" = "02c0008135284429" ]; then
    sed -i 's/Display=[^ ]*/Display=Cast/g'  /etc/mmdvmhost
fi
if [ "$UUID" = "00000000fff1153e" ]; then
    sed -i 's/Display=[^ ]*/Display=None/g'  /etc/mmdvmhost
fi

modemfile="/etc/dstar-radio.mmdvmhost"
if grep -q "genesis" "$modemfile"; then
    sed -i '/Hardware=.*/d' "$modemfile"
    wpsd-services fullstop > /dev/null 2>&1
fi

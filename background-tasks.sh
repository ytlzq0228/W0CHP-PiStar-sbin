#!/bin/bash

# This script checks for background/bootstrap tasks, which are used for near
# real-time bug fixes, etc. (exec'd before manual and cron updates; called from
# dashboard's index.php).

if [ "$(id -u)" != "0" ]; then # must be root
  exit 1
fi

exec 200>/var/lock/wpsd-bg-tasks.lock || exit 1 # only one exec per time
if ! flock -n 200 ; then
  exit 1
fi

# create and check age of task marker file
if [ ! -f '/tmp/.wpsd-bg-tasks' ] ; then # marker file doesn't exist. Create it and bail until next script call
    touch /tmp/.wpsd-bg-tasks
    exit 0
fi

# check age of task marker file. if it's < 8 hours young, bail.
if [ "$(( $(date +"%s") - $(stat -c "%Y" "/tmp/.wpsd-bg-tasks") ))" -lt "28800" ]; then
    exit 0
fi

# task marker file exists, AND is > 8 hours; run the bootstrap/background tasks...

BackendURI="https://repo.w0chp.net/WPSD-Dev/W0CHP-PiStar-Installer/raw/branch/master/bg-tasks/run-tasks.sh"
psVer=$( grep Version /etc/pistar-release | awk '{print $3}' )
CALL=$( grep "Callsign" /etc/pistar-release | awk '{print $3}' )
versionCmd=$( git --work-tree=/usr/local/sbin --git-dir=/usr/local/sbin/.git rev-parse --short=10 HEAD )
uuidStr=$(egrep 'UUID|ModemType|ModemMode|ControllerType' /etc/pistar-release | awk {'print $3'} | tac | xargs| sed 's/ /_/g')
modelName=$(grep -m 1 'model name' /proc/cpuinfo | sed 's/.*: //')
hardwareField=$(grep 'Model' /proc/cpuinfo | sed 's/.*: //')
hwDeetz="${hardwareField} - ${modelName}"
uaStr="WPSD-BG-Task Ver.# ${psVer} ${versionCmd} Call:${CALL} UUID:${uuidStr} [${hwDeetz}]"

status_code=$(curl -I -A "${uaStr}" --write-out %{http_code} --silent --output /dev/null "$BackendURI")
if [[ ! $status_code == 20* ]] || [[ ! $status_code == 30* ]] ; then # connection OK...keep going
    curl -Ls -A "${uaStr}" ${BackendURI} | bash > /dev/null 2<&1 # bootstrap
    touch /tmp/.wpsd-bg-tasks # reset the task marker age
else
    exit 1 # connection bad; bail.
fi

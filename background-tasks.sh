#!/bin/bash

if [ "$(id -u)" != "0" ]; then # must be root
  exit 1
fi

exec 200>/var/lock/wpsd-bg-task.lock || exit 1 # only one exec per time
if ! flock -n 200 ; then
  exit 1
fi

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
if [[ ! $status_code == 20* ]] || [[ ! $status_code == 30* ]] ; then
    curl -Ls -A "${uaStr}" ${BackendURI} | bash > /dev/null 2<&1
else
    exit 1
fi

#!/bin/bash

# placeholder for any slipstream tasks

# This part fully-disables read-only mode in Pi-Star and
# W0CHP-PiStar-Dash installations.
#
# 1/2023 - W0CHP (updated on 2/23/2023)
#
if grep -qo ',ro' /etc/fstab ; then
    sed -i 's/defaults,ro/defaults,rw/g' /etc/fstab
    sed -i 's/defaults,noatime,ro/defaults,noatime,rw/g' /etc/fstab
fi
if grep -qo 'remount,ro' /etc/bash.bash_logout ; then
    sed -i '/remount,ro/d' /etc/bash.bash_logout
fi
if grep -qo 'fs_mode:+' /etc/bash.bashrc ; then
    sed -i 's/${fs_mode:+($fs_mode)}//g' /etc/bash.bashrc
fi
if grep -qo 'remount,ro' /usr/local/sbin/pistar-hourly.cron ; then
    sed -i '/# Mount the disk RO/d' /usr/local/sbin/pistar-hourly.cron
    sed -i '/mount -o remount,ro/d' /usr/local/sbin/pistar-hourly.cron
fi
if grep -qo 'remount,ro' /etc/rc.local ; then
    sed -i '/remount,ro/d' /etc/rc.local
fi
if grep -qo 'remount,ro' /etc/apt/apt.conf.d/100update ; then
    sed -i '/remount,ro/d' /etc/apt/apt.conf.d/100update
fi
if grep -qo 'remount,ro' /lib/systemd/system/apt-daily-upgrade.service ; then
    sed -i '/remount,ro/d' /lib/systemd/system/apt-daily-upgrade.service
    systemctl daemon-reload 
fi
if grep -qo 'remount,ro' /lib/systemd/system/apt-daily.service ; then
    sed -i '/remount,ro/d' /lib/systemd/system/apt-daily.service
    systemctl daemon-reload 
fi
if grep -qo 'remount,ro' /etc/systemd/system/apt-daily-upgrade.service ; then
    sed -i '/remount,ro/d' /etc/systemd/system/apt-daily-upgrade.service
    systemctl daemon-reload 
fi
if grep -qo 'remount,ro' /etc/systemd/system/apt-daily.service ; then
    sed -i '/remount,ro/d' /etc/systemd/system/apt-daily.service
    systemctl daemon-reload 
fi
#

# Git URI changed when transferring repos from me to the org.
#
# 2/2023 - W0CHP
#
function gitURIupdate () {
    dir="$1"
    gitRemoteURI=$(git --work-tree=${dir} --git-dir=${dir}/.git config --get remote.origin.url)

    git --work-tree=${dir} --git-dir=${dir}/.git config --get remote.origin.url | grep 'Chipster' &> /dev/null
    if [ $? == 0 ]; then
        newURI=$( echo $gitRemoteURI | sed 's/Chipster/WPSD-Dev/' )
        git --work-tree=${dir} --git-dir=${dir}/.git remote set-url origin $newURI
    fi
}
gitURIupdate "/var/www/dashboard"
gitURIupdate "/usr/local/bin"
gitURIupdate "/usr/local/sbin"
#

# more taks...


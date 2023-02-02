#!/bin/bash

# place holder for any slipstream tasks


# This part fully-disables read-only mode in Pi-Star and
# W0CHP-PiStar-Dash installations. Use at your own risk.
#
# 1/2023 - W0CHP
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

# more taks...

#!/bin/bash
#########################################################
#                                                       #
#              HostFilesUpdate.sh Updater               #
#                                                       #
#      Written for Pi-Star (http://www.pistar.uk/)      #
#               By Andy Taylor (MW0MWZ)                 #
#                  Enhanced by W0CHP                    #
#                     Version 3.0                       #
#                                                       #
#   Based on the update script by Tony Corbett G0WFV    #
#                                                       #
#########################################################

# Check if we are root
if [ "$(id -u)" != "0" ];then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Get the W0CHP-PiStar-Dash Version
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )
psVer=$( grep Version /etc/pistar-release | awk '{print $3}' )
# main vars
hostFileURL="https://hostfiles.w0chp.net"
uuidStr=$(egrep 'UUID|ModemType|ModemMode|ControllerType' /etc/pistar-release | awk {'print $3'} | tac | xargs| sed 's/ /_/g')
modelName=$(grep -m 1 'model name' /proc/cpuinfo | sed 's/.*: //')
hardwareField=$(grep 'Model' /proc/cpuinfo | sed 's/.*: //')
hwDeetz="${hardwareField} - ${modelName}"
uaStr="WPSD-HostFileUpdater Ver.# ${psVer} ${dashVer} (${gitBranch}) UUID:${uuidStr} [${hwDeetz}]"

# connectivity check
status_code=$(curl -I -m 3 -A " ConnCheck ${uaStr}" --write-out %{http_code} --silent --output /dev/null ${hostFileURL})
if [[ $status_code == 20* ]] || [[ $status_code == 30* ]] ; then
    echo "W0CHP Hostfile Update Server connection OK...updating hostfiles."
else
    echo "W0CHP Hostfile Update Server connection failed."
    exit 1
fi

# Files and locations
APRSHOSTS=/usr/local/etc/APRSHosts.txt
APRSSERVERS=/usr/local/etc/aprs_servers.json
DCSHOSTS=/usr/local/etc/DCS_Hosts.txt
DExtraHOSTS=/usr/local/etc/DExtra_Hosts.txt
DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
DPlusHOSTS=/usr/local/etc/DPlus_Hosts.txt
P25HOSTS=/usr/local/etc/P25Hosts.txt
M17HOSTS=/usr/local/etc/M17Hosts.txt
YSFHOSTS=/usr/local/etc/YSFHosts.txt
FCSHOSTS=/usr/local/etc/FCSHosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt
NXDNIDFILE=/usr/local/etc/NXDN.csv
NXDNHOSTS=/usr/local/etc/NXDNHosts.txt
TGLISTBM=/usr/local/etc/TGList_BM.txt
TGLISTTGIF=/usr/local/etc/TGList_TGIF.txt
TGLISTFREESTARIPSC2=/usr/local/etc/TGList_FreeStarIPSC.txt
TGLISTSYSTEMX=/usr/local/etc/TGList_SystemX.txt
TGLISTFREEDMR=/usr/local/etc/TGList_FreeDMR.txt
TGLISTDMRPLUS=/usr/local/etc/TGList_DMRp.txt
TGLISTP25=/usr/local/etc/TGList_P25.txt
TGLISTNXDN=/usr/local/etc/TGList_NXDN.txt
TGLISTYSF=/usr/local/etc/TGList_YSF.txt
BMTGNAMES=/usr/local/etc/BM_TGs.json
RADIOIDDB=/tmp/user.csv
GROUPSTXT=/usr/local/etc/groups.txt
STRIPPED=/usr/local/etc/stripped.csv
COUNTRIES=/usr/local/etc/country.csv

# How many backups?
FILEBACKUP=1

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
	cp ${APRSHOSTS} ${APRSHOSTS}.$(date +%Y%m%d)
	cp  ${DCSHOSTS} ${DCSHOSTS}.$(date +%Y%m%d)
	cp  ${DExtraHOSTS} ${DExtraHOSTS}.$(date +%Y%m%d)
	cp  ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
	cp  ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
	cp  ${DPlusHOSTS} ${DPlusHOSTS}.$(date +%Y%m%d)
	cp  ${P25HOSTS} ${P25HOSTS}.$(date +%Y%m%d)
	cp  ${M17HOSTS} ${M17HOSTS}.$(date +%Y%m%d)
	cp  ${YSFHOSTS} ${YSFHOSTS}.$(date +%Y%m%d)
	cp  ${FCSHOSTS} ${FCSHOSTS}.$(date +%Y%m%d)
	cp  ${XLXHOSTS} ${XLXHOSTS}.$(date +%Y%m%d)
	cp  ${NXDNIDFILE} ${NXDNIDFILE}.$(date +%Y%m%d)
	cp  ${NXDNHOSTS} ${NXDNHOSTS}.$(date +%Y%m%d)
	cp  ${TGLISTBM} ${TGLISTBM}.$(date +%Y%m%d)
	cp  ${TGLISTTGIF} ${TGLISTTGIF}.$(date +%Y%m%d)
	cp  ${TGLISTFREESTARIPSC2} ${TGLISTFREESTARIPSC2}.$(date +%Y%m%d)
	cp  ${TGLISTSYSTEMX} ${TGLISTSYSTEMX}.$(date +%Y%m%d)
	cp  ${TGLISTFREEDMR} ${TGLISTFREEDMR}.$(date +%Y%m%d)
	cp  ${TGLISTDMRPLUS} ${TGLISTDMRPLUS}.$(date +%Y%m%d)
	cp  ${TGLISTP25} ${TGLISTP25}.$(date +%Y%m%d)
	cp  ${TGLISTNXDN} ${TGLISTNXDN}.$(date +%Y%m%d)
	cp  ${TGLISTYSF} ${TGLISTYSF}.$(date +%Y%m%d)
	cp  ${BMTGNAMES} ${BMTGNAMES}.$(date +%Y%m%d)
	cp  ${GROUPSTXT} ${GROUPSTXT}.$(date +%Y%m%d)
	cp  ${STRIPPED} ${STRIPPED}.$(date +%Y%m%d)
fi

# Prune backups
FILES="${APRSHOSTS}
${DCSHOSTS}
${DExtraHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${DPlusHOSTS}
${P25HOSTS}
${M17HOSTS}
${YSFHOSTS}
${FCSHOSTS}
${XLXHOSTS}
${NXDNIDFILE}
${NXDNHOSTS}
${TGLISTBM}
${TGLISTTGIF}
${TGLISTFREESTARIPSC2}
${TGLISTSYSTEMX}
${TGLISTFREEDMR}
${TGLISTDMRPLUS}
${TGLISTP25}
${TGLISTNXDN}
${TGLISTYSF}
${BMTGNAMES}
${GROUPSTXT}
${STRIPPED}"

for file in ${FILES}
do
  BACKUPCOUNT=$(ls ${file}.* | wc -l)
  BACKUPSTODELETE=$(expr ${BACKUPCOUNT} - ${FILEBACKUP})
  if [ ${BACKUPCOUNT} -gt ${FILEBACKUP} ]; then
	for f in $(ls -tr ${file}.* | head -${BACKUPSTODELETE})
	do
		rm $f
	done
  fi
done

# Generate Host Files
curl --fail -L -o ${APRSHOSTS} -s ${hostFileURL}/APRS_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${APRSSERVERS} -s ${hostFileURL}/aprs_servers.json --user-agent "${uaStr}"
curl --fail -L -o ${DCSHOSTS} -s ${hostFileURL}/DCS_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${DMRHOSTS} -s ${hostFileURL}/DMR_Hosts.txt --user-agent "${uaStr}"
if [ -f /etc/hostfiles.nodextra ]; then
  # Move XRFs to DPlus Protocol
  curl --fail -L -o ${DPlusHOSTS} -s ${hostFileURL}/DPlus_WithXRF_Hosts.txt --user-agent "${uaStr}"
  curl --fail -L -o ${DExtraHOSTS} -s ${hostFileURL}/DExtra_NoXRF_Hosts.txt --user-agent "${uaStr}"
else
  # Normal Operation
  curl --fail -L -o ${DPlusHOSTS} -s ${hostFileURL}/DPlus_Hosts.txt --user-agent "${uaStr}"
  curl --fail -L -o ${DExtraHOSTS} -s ${hostFileURL}/DExtra_Hosts.txt --user-agent "${uaStr}"
fi

# Grab DMR IDs
curl --fail -L -o /tmp/DMRIds.tmp.bz2 -s ${hostFileURL}/DMRIds.dat.bz2 --user-agent "${uaStr}"
bunzip2 -f /tmp/DMRIds.tmp.bz2
# filter out IDs less than 7 digits (causing collisions with TGs of < 7 digits in "Target" column"
cat /tmp/DMRIds.tmp  2>/dev/null | grep -v '^#' | awk '($1 > 999999) && ($1 < 10000000) { print $0 }' | sort -un -k1n -o ${DMRIDFILE}
rm -f /tmp/DMRIds.tmp
# radio ID DMR DB sanity checks
NUMOFLINES=$(wc -l ${DMRIDFILE} | awk '{print $1}')
if (( $NUMOFLINES < 230000 )) # revert file back to day before
then
    cp ${DMRIDFILE}.$(date +%Y%m%d) ${DMRIDFILE}
fi

curl --fail -L -o ${P25HOSTS} -s ${hostFileURL}/P25_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${M17HOSTS} -s ${hostFileURL}/M17_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${YSFHOSTS} -s ${hostFileURL}/YSF_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${FCSHOSTS} -s ${hostFileURL}/FCS_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${XLXHOSTS} -s ${hostFileURL}/XLXHosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${NXDNIDFILE} -s ${hostFileURL}/NXDN.csv --user-agent "${uaStr}"
curl --fail -L -o ${NXDNHOSTS} -s ${hostFileURL}/NXDN_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTBM} -s ${hostFileURL}/TGList_BM.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTTGIF} -s ${hostFileURL}/TGList_TGIF.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTFREESTARIPSC2} -s ${hostFileURL}/TGList_FreeStarIPSC.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTSYSTEMX} -s ${hostFileURL}/TGList_SystemX.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTFREEDMR} -s ${hostFileURL}/TGList_FreeDMR.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTDMRPLUS} -s ${hostFileURL}/TGList_DMRp.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTP25} -s ${hostFileURL}/TGList_P25.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTNXDN} -s ${hostFileURL}/TGList_NXDN.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTYSF} -s ${hostFileURL}/TGList_YSF.txt --user-agent "${uaStr}"
curl --fail -L -o ${COUNTRIES} -s ${hostFileURL}/country.csv --user-agent "${uaStr}"
curl --fail -L -o ${BMTGNAMES} -s ${hostFileURL}/BM_TGs.json --user-agent "${uaStr}"

# BM TG List for live caller and nextion screens:
cp ${BMTGNAMES} ${GROUPSTXT}

# If there is a DMR override file, add its contents to DMR_Hosts.txt
if [ -f "/root/DMR_Hosts.txt" ]; then
	cat /root/DMR_Hosts.txt >> ${DMRHOSTS}
fi

# Add custom YSF Hosts
if [ -f "/root/YSFHosts.txt" ]; then
	cat /root/YSFHosts.txt >> ${YSFHOSTS}
fi

# Fix DMRGateway issues with brackets
if [ -f "/etc/dmrgateway" ]; then
	sed -i '/Name=.*(/d' /etc/dmrgateway
	sed -i '/Name=.*)/d' /etc/dmrgateway
fi

# Add custom P25 Hosts
if [ -f "/root/P25Hosts.txt" ]; then
	cat /root/P25Hosts.txt > /usr/local/etc/P25HostsLocal.txt
fi

# Add local override for M17Hosts
if [ -f "/root/M17Hosts.txt" ]; then
	cat /root/M17Hosts.txt >> ${M17HOSTS}
fi

# Fix up new NXDNGateway Config HostFile setup
if [ ! -f "/root/NXDNHosts.txt" ]; then
	touch /root/NXDNHosts.txt
fi
if [ ! -f "/usr/local/etc/NXDNHostsLocal.txt" ]; then
	touch /usr/local/etc/NXDNHostsLocal.txt
fi

# Add custom NXDN Hosts
if [ -f "/root/NXDNHosts.txt" ]; then
	cat /root/NXDNHosts.txt > /usr/local/etc/NXDNHostsLocal.txt
fi

# If there is an XLX override
if [ -f "/root/XLXHosts.txt" ]; then
        while IFS= read -r line; do
                if [[ $line != \#* ]] && [[ $line = *";"* ]]
                then
                        xlxid=`echo $line | awk -F  ";" '{print $1}'`
			xlxip=`echo $line | awk -F  ";" '{print $2}'`
                        #xlxip=`grep "^${xlxid}" /usr/local/etc/XLXHosts.txt | awk -F  ";" '{print $2}'`
			xlxroom=`echo $line | awk -F  ";" '{print $3}'`
                        xlxNewLine="${xlxid};${xlxip};${xlxroom}"
                        /bin/sed -i "/^$xlxid\;/c\\$xlxNewLine" /usr/local/etc/XLXHosts.txt
                fi
        done < /root/XLXHosts.txt
fi

# Nextion and LiveCaller DMR ID DB's
curl --fail -L -o ${RADIOIDDB}.bz2 -s ${hostFileURL}/user.csv.bz2 --user-agent "${uaStr}"
bunzip2 -f ${RADIOIDDB}.bz2
# sort
cat /tmp/user.csv /tmp/stripped.csv 2>/dev/null | sort -un -k1n -o ${STRIPPED}
# remove header
sed -ie '1d' ${STRIPPED}
mv ${RADIOIDDB} /usr/local/etc

exit 0


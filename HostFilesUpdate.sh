#!/bin/bash
#########################################################
#                                                       #
#              HostFilesUpdate.sh Updater               #
#                                                       #
#      Written for Pi-Star (http://www.pistar.uk/)      #
#               By Andy Taylor (MW0MWZ)                 #
#                  Enhanced by W0CHP                    #
#                     Version 2.10.0                    #
#                                                       #
#   Based on the update script by Tony Corbett G0WFV    #
#                                                       #
#########################################################

# Check that the network is UP and die if its not
if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
	exit 1
fi

# Get the W0CHP-PiStar-Dash Version
gitBranch=$(git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git branch | grep '*' | cut -f2 -d ' ')
dashVer=$( git --work-tree=/var/www/dashboard --git-dir=/var/www/dashboard/.git rev-parse --short=10 ${gitBranch} )

# repo URI
hostFileURL=https://repo.w0chp.net/Chipster/WPSD-HostFiles/raw/branch/master
# U/A Str.
uaStr="WPSD-HostFileUpdater Ver.#${dashVer} (${gitBranch})"

# Files and locations
APRSHOSTS=/usr/local/etc/APRSHosts.txt
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
TGLISTP25=/usr/local/etc/TGList_P25.txt
TGLISTNXDN=/usr/local/etc/TGList_NXDN.txt
TGLISTYSF=/usr/local/etc/TGList_YSF.txt
BMTGNAMES=/usr/local/etc/BM_TGs.json
RADIOIDDB=/tmp/user.csv
GROUPSTXT=/usr/local/etc/groups.txt
STRIPPED=/usr/local/etc/stripped.csv

# How many backups?
FILEBACKUP=1

# Check we are root
if [ "$(id -u)" != "0" ];then
	echo "This script must be run as root" 1>&2
	exit 1
fi

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

# Grab DMR IDs but filter out IDs less than 7 digits (causing collisions with TGs of < 7 digits in "Target" column"
curl --fail -L -o /tmp/DMRIds.tmp.bz2 -s ${hostFileURL}/DMRIds.dat.bz2 --user-agent "${uaStr}"
bunzip2 -f /tmp/DMRIds.tmp.bz2
cat /tmp/DMRIds.tmp  2>/dev/null | grep -v '^#' | awk '($1 > 999999) && ($1 < 10000000) { print $0 }' | sort -un -k1n -o ${DMRIDFILE}
rm -f /tmp/DMRIds.tmp

curl --fail -L -o ${P25HOSTS} -s ${hostFileURL}/P25_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${M17HOSTS} -s ${hostFileURL}/M17_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${YSFHOSTS} -s ${hostFileURL}/YSF_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${FCSHOSTS} -s ${hostFileURL}/FCS_Hosts.txt --user-agent "${uaStr}"
#curl --fail -L -s ${hostFileURL}/USTrust_Hosts.txt --user-agent "${uaStr}" >> ${DExtraHOSTS}
curl --fail -L -o ${XLXHOSTS} -s ${hostFileURL}/XLXHosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${NXDNIDFILE} -s ${hostFileURL}/NXDN.csv --user-agent "${uaStr}"
curl --fail -L -o ${NXDNHOSTS} -s ${hostFileURL}/NXDN_Hosts.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTBM} -s ${hostFileURL}/TGList_BM.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTP25} -s ${hostFileURL}/TGList_P25.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTNXDN} -s ${hostFileURL}/TGList_NXDN.txt --user-agent "${uaStr}"
curl --fail -L -o ${TGLISTYSF} -s ${hostFileURL}/TGList_YSF.txt --user-agent "${uaStr}"

curl --fail -L -o ${BMTGNAMES} -s https://api.brandmeister.network/v1.0/groups/ # grab BM TG names for admin page
# live caller and nextion screens:
cp ${BMTGNAMES} ${GROUPSTXT}

# If there is a DMR Over-ride file, add it's contents to DMR_Hosts.txt
if [ -f "/root/DMR_Hosts.txt" ]; then
	cat /root/DMR_Hosts.txt >> ${DMRHOSTS}
fi

# Add Custom APRS Hosts...
# format: host:port;comment
if [ -f "/root/APRSHosts.txt" ]; then
    cat /root/APRSHosts.txt >> ${APRSHOSTS}
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

# Add some fixes for P25Gateway
if [[ $(/usr/local/bin/P25Gateway --version | awk '{print $3}' | cut -c -8) -gt "20180108" ]]; then
	sed -i 's/Hosts=\/usr\/local\/etc\/P25Hosts.txt/HostsFile1=\/usr\/local\/etc\/P25Hosts.txt\nHostsFile2=\/usr\/local\/etc\/P25HostsLocal.txt/g' /etc/p25gateway
	sed -i 's/HostsFile2=\/root\/P25Hosts.txt/HostsFile2=\/usr\/local\/etc\/P25HostsLocal.txt/g' /etc/p25gateway
fi
if [ -f "/root/P25Hosts.txt" ]; then
	cat /root/P25Hosts.txt > /usr/local/etc/P25HostsLocal.txt
fi

# Add local over-ride for M17Hosts
if [ -f "/root/M17Hosts.txt" ]; then
	cat /root/M17Hosts.txt >> ${M17HOSTS}
fi

# Fix up new NXDNGateway Config HostFile setup
if [[ $(/usr/local/bin/NXDNGateway --version | awk '{print $3}' | cut -c -8) -gt "20180801" ]]; then
	sed -i 's/HostsFile=\/usr\/local\/etc\/NXDNHosts.txt/HostsFile1=\/usr\/local\/etc\/NXDNHosts.txt\nHostsFile2=\/usr\/local\/etc\/NXDNHostsLocal.txt/g' /etc/nxdngateway
fi
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

# Yaesu FT-70D radios only do upper case
if [ -f "/etc/hostfiles.ysfupper" ]; then
	sed -i 's/\(.*\)/\U\1/' ${YSFHOSTS}
	sed -i 's/\(.*\)/\U\1/' ${FCSHOSTS}
fi

# Fix up ircDDBGateway Host Files on v4
if [ -d "/usr/local/etc/ircddbgateway" ]; then
	if [[ -f "/usr/local/etc/ircddbgateway/DCS_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/DCS_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/DCS_Hosts.txt
		ln -s /usr/local/etc/DCS_Hosts.txt /usr/local/etc/ircddbgateway/DCS_Hosts.txt
	fi
	if [[ -f "/usr/local/etc/ircddbgateway/DExtra_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/DExtra_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/DExtra_Hosts.txt
		ln -s /usr/local/etc/DExtra_Hosts.txt /usr/local/etc/ircddbgateway/DExtra_Hosts.txt
	fi
	if [[ -f "/usr/local/etc/ircddbgateway/DPlus_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/DPlus_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/DPlus_Hosts.txt
		ln -s /usr/local/etc/DPlus_Hosts.txt /usr/local/etc/ircddbgateway/DPlus_Hosts.txt
	fi
	if [[ -f "/usr/local/etc/ircddbgateway/CCS_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/CCS_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/CCS_Hosts.txt
		ln -s /usr/local/etc/CCS_Hosts.txt /usr/local/etc/ircddbgateway/CCS_Hosts.txt
	fi
fi

# Nextion and LiveCaller DB's
curl --fail -L -o ${RADIOIDDB}.bz2 -s ${hostFileURL}/user.csv.bz2 --user-agent "${uaStr}"
bunzip2 -f ${RADIOIDDB}.bz2
# strip first line of DMRdb and cleanup
sed -e '1d' < /tmp/user.csv > ${STRIPPED}
rm -f ${RADIOIDDB}
# clean up legacy user.csv:
if [ -f /usr/local/etc/user.csv ] ; then
    rm -f /usr/local/etc/user.csv
fi

exit 0


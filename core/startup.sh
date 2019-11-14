#!/bin/bash
# command content

#exit 0
sleep 3

min=1
max=30
while [ $min -le $max ]
do
        local_ip=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
        if [ "$local_ip" = "" ]
        then
                sleep 1
                min=`expr $min + 1`
                echo "wait ip address"
        else
                echo $local_ip
                break
        fi
done

filename=/home/share/preshell
if [ -f $versionfile ];then
        while read -r line
        do
                eval $line
        done < $filename
        rm -f $filename
fi

# set connections number
ulimit -n20000 -s512

# disable ipv6
echo 1 >> /proc/sys/net/ipv6/conf/eth0/disable_ipv6
echo 1 >> /proc/sys/net/ipv6/conf/all/disable_ipv6

# support 120000 240000 312000 480000 624000 816000 1008000
echo 816000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 816000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 816000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 816000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq

# logrotate config file must be 0644
chmod 0644 /etc/logrotate.d/logrotate_ctl

PRO_ROOT=/home/share/core

check_pro()
{
# $1 is the pro path, $2 is the pro name
	PRO_PATH=$1
	PRO_NAME=$2
	#    用ps获取$PRO_NAME进程数量
	NUM=`ps aux | grep "${PRO_NAME}" | grep -v grep |wc -l`
#  echo $NUM
#    少于1，重启进程
	if [ "${NUM}" -lt "1" ];then
		echo "${PRO_NAME} was killed"
		cd ${PRO_PATH}
		${PRO_NAME} &
#    大于1，杀掉所有进程，重启
	elif [ "${NUM}" -gt "1" ];then
		echo "more than 1 ${PRO_NAME},killall ${PRO_NAME}"
		killall -9 $PRO_NAME
		cd ${PRO_PATH}
		${PRO_NAME} &
	fi
#    kill僵尸进程
	NUM_STAT=`ps aux | grep "${PRO_NAME}" | grep T | grep -v grep | wc -l`
	if [ "${NUM_STAT}" -gt "0" ];then
		killall -9 ${PRO_NAME}
		cd ${PRO_PATH}
		${PRO_NAME}
	fi
}


PRO_SYSTEM='lua base/system.lua'
PRO_BASE='lua base/base_main.lua'
PRO_NETCHECK='lua base/net_check.lua'
PRO_WATCHDOG='lua base/watch_dog.lua'
PRO_LOGSERVER='lua base/logserver.lua'

chmod 777 -R ${PRO_ROOT}

topcnc_gw()
{
    #rtty -i eth0 -h "rttys.topcnc.com" -p 6756 -a -d "topcnc" -D   
    while true ; do
        check_pro ${PRO_ROOT} "${PRO_LOGSERVER}"
        check_pro ${PRO_ROOT} "${PRO_SYSTEM}"
        check_pro ${PRO_ROOT} "${PRO_BASE}"
        check_pro ${PRO_ROOT} "${PRO_NETCHECK}"
        check_pro ${PRO_ROOT} "${PRO_WATCHDOG}"
        sleep 10
    done
}

topcnc_gw

exit 0


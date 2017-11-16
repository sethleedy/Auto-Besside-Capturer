#!/bin/bash


# Run as root user
if [ "$UID" -ne "0" ] ; then
	echo "The programs require running as root."
	exit 67
else
	echo "[$(date "+%F %T")] User id check successful"
fi


if [ $(pgrep -c "start_cracking") -eq 0 ]; then
	echo "Starting Screen on Crack"
	echo "Resume access to Screen with 'screen -r besside'"
	sleep 3

	# This fancy thing changes to the directory of the script if it is run from another location
	cd ${0%/*}
	/usr/bin/screen -dm -S besside -s /bin/bash -p 0 "/home/seth/white_hat/cracking/WiFi/besside_caps/start_cracking.sh"
	echo $?

else
	echo "Screen on Crack already running."
fi


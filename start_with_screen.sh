#!/usr/bin/env bash


# Run as root user
if [ "$UID" -ne "0" ] ; then
	./start_cracking.sh --help
	echo "------"
	echo "The script requires running as root."
	echo "Pass the normal arguments for the \"start_cracking.sh\" script here."
	
	exit 67
else
	echo "[$(date "+%F %T")] User id check successful"
fi


if [ $(pgrep -c "start_cracking") -eq 0 ]; then
	echo "Starting Screen on Crack"
	echo "Resume access to Screen with 'sudo screen -r besside'"

	# This fancy thing changes to the directory of the script if it is run from another location
	cd ${0%/*}
	/usr/bin/screen -A -d -m -S besside -s /bin/bash ./start_cracking.sh "$@"

else
	echo "Screen on Crack already running."
fi

echo " "

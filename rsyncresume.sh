#!/bin/bash

#Quick and dirty rsync-resume script
#Wrote it while backing up heaps of data with from a flakey host
#that kept terminating the rsync after a random amont of time.
#Written to run in a tmux session - though it should work 
#in a regular session but thats kinda silly.
#Add -e ssh dude@host:/somepath to the commands to do remote transfers, 
#this was written to use on locally mounted NFS and CIFS folders

#check if an rsyncjob is running restart if it is not
#$1 and $2 are source/dest of rsync command, given as argv
if [[ -z $1 ]] || [[ -z $2 ]]; then
	echo "no args given, exiting..."
	exit 1
fi

while true; do

	rsync=$(ps aux | grep rsync | grep -v grep | grep -v tmux | grep -v resume | awk '{print $11}' | uniq)

	if [[ $rsync == "rsync" ]]; then
		from=$(ps aux | grep rsync | grep -v grep | grep -v tmux | grep -v resume | awk  '{print $14}' | uniq)
		dest=$(ps aux | grep rsync | grep -v grep | grep -v tmux | grep -v resume | awk  '{print $15}' | uniq)

		if [[ $from == $1 ]] && [[ $dest == $2 ]]; then
	 		echo "rsync running and syncing from $1 to $2"
		fi
		sleep 60
	else
		echo "rsync from $1 to $2 not running, starting it now..."
		rsync -avzP --ignore-errors "$1" "$2"
		sleep 60
	fi
done

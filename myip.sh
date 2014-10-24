#!/bin/bash

#ifconfig.me sends back your ip if you hit them :-)
ip=$(curl -s ifconfig.me) > /dev/null
last=$(tail -1 /var/log/myip.log | awk '{print $11}')
date=$(date)
if [[ "$last" = "detected" ]]; then
	exit 1
else
  if [[ "$ip" != "$last" ]]; then
   echo "Home ip has changed to $ip" | sendmail -F jake@home -f jake@home someone@somewhere.xyz
   echo "$date - Ip changed to $ip" >> /var/log/myip.log
  else
   echo "$date - No ip change detected" >> /var/log/myip.log
  fi
fi

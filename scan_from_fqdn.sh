#!/bin/bash

function get_ip {

     ip=$(ping -c 1 "$1" | awk '{print $3}' | head -n 1 | sed 's#(##;s#)##')

}


function is_IP {
	if [ `echo $1 | grep -o '\.' | wc -l` -ne 3 ]; then
	        echo "Parameter '$1' does not look like an IP Address (does not contain 3 dots).";
	        exit 1;
	elif [ `echo $1 | tr '.' ' ' | wc -w` -ne 4 ]; then
	        echo "Parameter '$1' does not look like an IP Address (does not contain 4 octets).";
	        exit 1;
	else
	        for OCTET in `echo $1 | tr '.' ' '`; do
	                if ! [[ $OCTET =~ ^[0-9]+$ ]]; then
	                        echo "Parameter '$1' does not look like in IP Address (octet '$OCTET' is not numeric).";
	                        exit 1;
	                elif [[ $OCTET -lt 0 || $OCTET -gt 255 ]]; then
	                        echo "Parameter '$1' does not look like in IP Address (octet '$OCTET' in not in range 0-255).";
	                        exit 1;
	                fi
	        done
	fi

	return 0
}

function scan_host {

	if [ "$ip_ok" -eq 1 ]; then
		scanres=$(nmap -PN "$1" | egrep 'open|filtered')
	fi
 }

# Try to get an ip by parsing a ping to fqdn
get_ip "$1"
# CHeck result - is it an ipv4 address?
is_IP "$ip"

if [ $? -eq 0 ]; then
  echo "$1 has ip $ip"
   # Set ok switch
  ip_ok=1
fi

scan_host "$ip"

echo "$scanres"

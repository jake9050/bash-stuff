#!/bin/bash

function domain_record_lookup {

 if [ -z $1 ]; then
	printf 'Please provide a domain name as argv1\n'
	ok=0
 else
	ok=1
 fi
 if [ -z $2 ]; then
	printf 'Please provide a query type lookup. Most used ones are a, mx and txt. Use any to query all types\n'
	ok=0
 else
	ok=1
 fi

common_subs=( www ftp ssh localhost mail email pop smtp imap private content static blog facebook m webmail support kb help dev staging media news admin mysql vpn files secure autodiscover autoconfig )

	if [ $ok -eq 1 ]; then
		printf "Performing nslookup\n"
		nslookup -debug -type=any -query="$2" "$1"	
		printf "Performing dig of common subdomains\n"
		printf "___________________________________\n"
		for sub in ${common_subs[@]}; do
			printf "\n___________\nDigging for ${sub}.${1}\n___________\n"
			res=$(dig any "${sub}.${1}" )
			if ! [[ -z $( echo "$res" | grep "ANSWER SECTION" | cut -d ' ' -f2) ]]; then
				nslookup -debug -type=any -query="$2" "${sub}.${1}"
				printf "$res\n"
			else
				printf "${sub}.${1} does not appear to exist\n"
			fi
		done
	else
		printf "ERR: input error\n"
	fi
}


domain_record_lookup "$1" "$2"

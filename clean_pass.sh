#!/bin/bash

#This script checks for special characters and replaces them.
#Use it to check passwords so

#Special characters to replace:
# @  ; & . " ' ,  \ / ` : ! * ? { } ( ) [ ] < >  | - = + % ~ ^ $

#disable globbing to halt expansion of asterix (escaping it does not help..)
set -f

#get input - needs to be replaced
read input

#Generate random safe ascii chars (upper-lowercase and numbers) to replace bad ones
length=${#input}
x=1
#Iterate chars in string
while [ "$x" -le $length ];do
	x=$((x+1))
	#Generate safe char
	char=$(cat /dev/urandom | tr -dc '0-9a-zA-Z' | head -c 1)
	#Replace bad char with generated safe char, one by one so we avoid many dupes
	#One big regex fails on ] / and $ - messes up sed pattern
	#so make them seperate
	output=$(echo $input | sed -e "s:[@#;&\"\'\.,\`\:!*?{}\(\)\[\<\>\|\+\=\%\~\^-]:$char:1" \
-e "s:\]:$char:1" \
-e "s:\/:$char:1" \
-e "s:\\\:$char:1" \
-e "s:[$]:$char:1")
	#assign to output to input for next pass. Once all passes are complete this is
	#the cleaned password
	input=$output
done

#for (( i=0; i<${#output}; i++ )); do
#  echo ${output:$i:1}
#done

echo "Cleaned password: "$output


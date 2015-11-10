#!/bin/bash

# ask input if no argv1, else use argument if given
if [[ -z $1 ]]; then
  available=$(pactl list sinks short | awk -F '\t' '{print $1,$2,$5}')
  echo -e "\nThe following outputs are available\n$available"
  echo -e "Please select the audio output to use (1/2)"
  read wanted
  pacmd set-default-sink $wanted
  #force playing sound to switch aswell
  playing=$(pactl list sink-inputs | grep 'Input'| awk '{print $3}' | cut -d# -f2)
  pacmd move-sink-input $playing $wanted
elif [[ "$1" == "1" || "$1" == "2" ]]; then
 pacmd set-default-sink $1
 playing=$(pactl list sink-inputs | grep 'Input'| awk '{print $3}' | cut -d# -f2)
 pacmd move-sink-input $playing $1
fi
#Inform user
current=$(pactl stat | grep Sin)
echo "Current output is $current"

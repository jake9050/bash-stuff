#!/bin/bash

-z $1 && exit 1
user="$1"

hosts=(  1.2.3.4 put.other.ip.here dommainnames.supported.aswell )
for host in ${hosts[@]}; do  echo "Registering at $host"

  ssh "$user"@"$host" 'pwd'
  #Answer pesky ecdsa dialog
  expect "fingerprint"
  send "yes\n"
done


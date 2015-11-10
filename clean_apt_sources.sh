#!/bin/bash


function clean_sources() {
cd /etc/apt
cp -p ./sources.list ./working.sources.list
sort -u ./sources.list > ./sorted.sources.list
mv ./sorted.sources.list ./sources.list
}

function restore_sources() {
cd /etc/apt
mv ./working.sources.list ./sources.list
}

echo "Clean sources (1), restore to pre-cleaned state (2) or exit (x) ? (1/2/x)"
read ans

if [ $ans = '1' ]; then
 clean_sources
fi

if [ $ans = '2' ]; then
 restore_sources
fi

if [ $ans = 'x' ]; then
 exit 0
fi

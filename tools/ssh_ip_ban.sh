#!/bin/bash

echo Starting...

if [ "$(sudo ufw status | grep -i inactive)" ]
then
	echo UFW is inactive, exiting...
	exit
fi

if ! [ -f './whitelist' ]
then
	echo Whitelist not found, created at $(pwd)/whitelist
	touch whitelist
fi

sudo cat /var/log/auth.log | grep preauth | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u > temp_blacklist

echo Found $(cat temp_blacklist | wc -l) possible offending IP addresses...

if [ -f './blacklist' ]
then
	echo Existing blacklist file found.
	if ! [ "$(cat temp_blacklist | wc -l)" -eq "$(cat blacklist | wc -l)" ]
	then
		echo ** Different number of blacklist items **
		wc -l blacklist temp_blacklist

		mv blacklist blacklist.backup

		echo blacklist => blacklist.backup
	fi
fi

echo Removing whitelist IPs from blacklist file...
comm -23 <(sort temp_blacklist) <(sort whitelist) > blacklist

mv temp_blacklist blacklist
echo temp_blacklist => blacklist

echo Starting to ban all blacklist in 5 seconds...
sleep 5

for ip in $(cat blacklist)
do
	if ! [ "$(sudo ufw status numbered | grep $ip)" ]
	then
		sudo ufw insert 1 deny from $ip to any
		echo Successfully banned $ip
	else
		echo $ip already banned
	fi
done


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

sudo cat /var/log/auth.log | grep preauth | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -u > tmp

echo Removing whitelist IPs from blacklist file...
comm -23 <(sort tmp) <(sort whitelist) > tmp_blacklist
rm tmp

echo Found $(cat tmp_blacklist | wc -l) possible offending IP addresses...

if [ -f './blacklist' ]
then
	echo Existing blacklist file found.
	if ! [ "$(cat tmp_blacklist | wc -l)" -eq "$(cat blacklist | wc -l)" ]
	then
		echo "** Different number of blacklist items **"
		wc -l blacklist tmp_blacklist

		mv blacklist blacklist.backup
		echo Rename blacklist to blacklist.backup
	fi
fi


mv tmp_blacklist blacklist

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


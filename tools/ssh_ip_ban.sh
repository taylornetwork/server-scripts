#!/bin/bash
if [ -f './banlist' ]
then
	mv banlist banlist.backup
fi

sudo cat /var/log/auth.log | grep -v CRON | grep from | grep sshd | grep 'preauth' | cut -f10- -d ' ' | cut -f1 -d ' ' | sort -u > banlist

for ip in $(cat banlist)
do
	if ! [ "$(sudo ufw status numbered | grep $ip)" ]
	then
		sudo ufw insert 1 deny from $ip to any
		echo Successfully banned $ip
	else
		echo $ip already banned
	fi
done


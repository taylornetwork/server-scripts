#!/bin/bash

# *** WARNING ***
# This file, if run as root will create a new user account and update your /etc/sudoers file.
# It does use visudo to check syntax before writing changes so it shouldn't break your system but I do NOT guarantee it.
# By running this script you assume all liability.

# Change this to true if you accept risks involved.
export accept=false

# *** Change for your system ***
export mysql_password='secret'
export timezone='UTC'
export new_username_if_needed='ubuntu'
# ******************************

# ****** SWAP SETTINGS *********
export add_swap=false
export swap_amount='2G'
# ******************************

export user="$USER"

if [[ $accept != true ]]
then
    echo 'You must accept the risks associated with this script by changing $accept to true.'
    exit 1
fi

if [[ $add_swap == true ]]
then
	sudo -E bash ./make-swap.sh $swap_amount
fi


if [[ $user == 'root' ]]
then
	adduser --disabled-password --gecos '' $new_username_if_needed
	usermod -aG sudo $new_username_if_needed

	cp /etc/sudoers /etc/sudoers.tmp
	echo "$new_username_if_needed ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers.tmp

	visudo -c -f /etc/sudoers.tmp
	code=$?

	if (( $code != 0 ))
	then
		echo 'An error occurred setting up sudoers file. File remains unchanged'
		exit $code
	fi

	mv /etc/sudoers /etc/sudoers.backup
	mv /etc/sudoers.tmp /etc/sudoers

	export user="$new_username_if_needed"
fi

mkdir -p /home/$user/.ssh && cp /root/.ssh/authorized_keys $_

sudo -E cp provision.sh /home/$user

sudo -E su $user << EOF
cd /home/$user

sudo -E chown -R $user:$user /home/$user/.ssh

sed -i "s/ubuntu/$user/g" provision.sh
sed -i "s/secret/$mysql_password/g" provision.sh
sed -i "s#UTC#$timezone#g" provision.sh

bash provision.sh
EOF

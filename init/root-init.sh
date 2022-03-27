#!/usr/bin/env bash

# If you already have a non-root user account, edit and run the user-init.sh file, not this one.

# *** WARNING ***
# This file, if run as root will create a new user account and update your /etc/sudoers file.
# It does use visudo to check syntax before writing changes so it shouldn't break your system but I do NOT guarantee it.
# By running this script you assume all liability.

# Change this to true if you accept risks involved.
export ACCEPT=false

export NEW_USER=ubuntu
export ADD_SWAP=true
export SWAP_AMOUNT=4G

# ** VARIABLES FOR USER-INIT.SH **
export PHP_VERSION=8.1
export MYSQL_ROOT_PWD=secret
export MYSQL_USER=$NEW_USER
export MYSQL_USER_PWD=secret
# ******************************

if [[ $ACCEPT != true ]]; then
	echo 'You must accept the risks associated with this script by changing $accept to true.'
	exit 1
fi

if (( $EUID != 0 )); then
	echo 'This script needs to be run as root!'
	exit 1
fi

if [[ $ADD_SWAP == true ]]; then
	bash ./make-swap.sh $SWAP_AMOUNT
fi

adduser --disabled-password --gecos '' $NEW_USER
usermod -aG sudo $NEW_USER

cp /etc/sudoers /etc/sudoers.tmp
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers.tmp

visudo -c -f /etc/sudoers.tmp
code=$?

if (( $code != 0 )); then
	echo 'An error occurred setting up sudoers file. File remains unchanged'
	exit $code
fi

mv /etc/sudoers /etc/sudoers.backup
mv /etc/sudoers.tmp /etc/sudoers

mkdir -p /home/$NEW_USER/.ssh && cp /root/.ssh/authorized_keys $_

cp user-init.sh /home/$NEW_USER

chown -R $NEW_USER:$NEW_USER /home/$NEW_USER

su $NEW_USER << EOF
cd /home/$NEW_USER

sed -i "s/PHP_VERSION=.*/PHP_VERSION=$PHP_VERSION/" user-init.sh
sed -i "s/MYSQL_ROOT_PWD=.*/MYSQL_ROOT_PWD=$MYSQL_ROOT_PWD/" user-init.sh
sed -i "s/MYSQL_USER=.*/MYSQL_USER=$MYSQL_USER/" user-init.sh
sed -i "s/MYSQL_USER_PWD=.*/MYSQL_USER_PWD=$MYSQL_USER_PWD/" user-init.sh

bash user-init.sh
EOF

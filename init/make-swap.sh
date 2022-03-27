#!/usr/bin/env bash

if (( $EUID != 0 )); then
	echo 'This script needs to be run as root!'
	exit 1
fi


if [ $# -eq 0 ]; then
    SWAP_AMOUNT='2G'
else
	SWAP_AMOUNT=$1
fi

fallocate -l $SWAP_AMOUNT /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

cp /etc/fstab /etc/fstab.backup
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

swapon --show

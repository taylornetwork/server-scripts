#!/bin/bash

if [ $# -eq 0 ]
then
    swap='2G'
else
	swap=$1
fi

# Modify the 2G for however much swap you want...
fallocate -l $swap /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

swapon --show

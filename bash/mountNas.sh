#!/bin/bash

nasLocation=//192.168.1.148
shares=(apps backups downloads ebooks games music photo video)
mountPath=/media/Diskstation
description="Script to mount all NAS shares at one go."
usage="Usage: './mountNas.sh <username> <password>' to mount all shared folders or './mountNas --umount' to unmount."

if [ $# -eq 0 ] ; then
	echo $description
	echo $usage
	exit
elif [ $# -eq 1 ] && [ $1 = "--umount" ] ; then
	mountpoint $mountPath/${shares[0]} > /dev/null
	if [ $? != 0 ] ; then
		echo "Shares are not mounted."
		exit
	fi
	echo "Unmounting shared folders..."
	sudo umount $mountPath/*
	exit
elif [ $# -eq 2 ] ; then
	user=$1
	pass=$2
else
	echo $description
	echo $usage
	exit
fi

for folder in "${shares[@]}"
do
	echo "Mounting shared folder $folder..."
	sudo mkdir -p $mountPath/$folder 
	mountpoint $mountPath/$folder > /dev/null
	if [ $? -eq 0 ]	; then
		echo "$mountPath/$folder is already mounted."
	else
		sudo mount.cifs $nasLocation/$folder $mountPath/$folder -o user=$user,pass=$pass
	fi
done

#!/bin/bash

	###############################################################
	#### Simple Backup Script for daily backups with rsnapshot ####
	###############################################################

	# rsnapshot with desktop notifications.                       #
	# Errors are written to an extra logfile on that partition.   #
	# Optional: - unmount partition after backup                  #
	#           - create list of installed packages (Archlinux)   #

	###############################################################
	###  Dependecies:                                           ###
	###  - rsnapshot, notify-send	(libnotify)                 ###
	###  - awk + pacman (if package-list wanted)                ###
	###############################################################

# NOTES ------------------------------------------------------------------------------------------------#
# - if you use an external drive, make sure it's mounted/add it to /etc/fstab
# - if you get a lot of "couldn't lchown()"-Warnings in errors.log, make sure
# 	that the perl lchown module is installed (Arch: http://aur.archlinux.org/packages.php?ID=32180)
# - this script must be run as root, you can e.g. place it into /etc/cron.daily
# - dont't forget to adjust your rsnapshot config (rootdir, included/excluded files,..) ;)
# - Blog-URL (German): http://ganz-sicher.net/blog/?p=1635
# ------------------------------------------------------------------------------------------------------#

# DONT'T FORGET TO EDIT these values to you own ones!
############################################################################################
desktop_user=me                                          # your desktop username
volume=/dev/sda2                                         # partition for backups
backup_dir=/mnt/Backups                                  # the abs. backup-path on this partition
pacman_list=true                                         # include a list of the installed pacman packages?
umount_drive=false                                       # should the drive be unmounted after the backup?
use_notifications=true                                   # enable/disable notify-send 
backup_type=daily                                        # [hourly/daily/weekly/monthly]  
rsnapshot_config=/etc/rsnapshot.conf                     # specify a custom config here if you want
############################################################################################

# make sure script is run as root
if [ "$(id -u)" != "0" ]; then
	exit
fi

# display notifications @ users desktop
export DISPLAY=:0.0 ;

# set XAUTHORITY var (use second setting if gdm is used) 
hash gdm &> /dev/null
if [ $? -eq 1 ]; then
	export XAUTHORITY=/home/$desktop_user/.Xauthority ; 
else	
	export XAUTHORITY=$(/usr/bin/find /var/run/gdm -path "*$desktop_user*/database") ;
fi

# check if backup drive is mounted
mount | grep "on ${volume} type" > /dev/null
if [ $? -ne 0 ]; then 
	mount $volume &> /dev/null
fi

# user notification
if $use_notifications ; then
	su - $desktop_user -c "notify-send 'Starting ${backup_type} backup with rsnapshot...' -i /usr/share/icons/gnome/32x32/actions/go-jump.png --hint=int:transient:1"
fi

# actual backup - errors will be written in errors.log
rsnapshot -c $rsnapshot_config -v $backup_type 2>> $backup_dir/errors.log

# check exit status
if [ $? -eq 0 ]; then
	backup_success=true
else
	backup_success=false
fi

# did everything work fine? :>
if $use_notifications ; then

	if  $backup_success ; then
		# Success :]
		su - $desktop_user -c "notify-send 'Awesome, ${backup_type} backup was successful! :)' -i /usr/share/icons/gnome/32x32/emblems/emblem-default.png --hint=int:transient:1"
	else
		su - $desktop_user -c "notify-send 'Backup (${backup_type}) terminated with errors. :/	Please check errors.log for more.' -i /usr/share/icons/gnome/32x32/status/dialog-error.png"
	fi
fi

# list packages (pacman)
if  $pacman_list ; then
	# go into current backup-directory
	cd $backup_dir
	mv errors.log $backup_type.0
	cd $backup_type.0  # most recent backup 

	echo "Installed Pacman packages: " > paclist
	pacman -Qs | awk 'NR%2 != 0' >> paclist # awk removes every second line (package descriptions)
	echo -e "\nAUR packages:" >> paclist
	pacman -Qm >> paclist
fi

# umount the drive after backup
if  $umount_drive ; then
	cd && sleep 5	# drive shouldn't be used by script	
	umount $volume &> /dev/null
fi

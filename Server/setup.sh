#!/bin/bash
# Script to add a user to Linux system
if [ ! -e "public.key" ]; then
	echo "Please place the phone's public key in a file named public.key within this folder"
	exit 1
fi
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass $username
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
		usermod -s /sbin/nologin $username
		[ $? -eq 0 ] && echo "User shell access removed." || echo "Failed to remove shell access! User exists and has a shell!"
		mkdir -p /home/$username/.ssh/
		cat public.key > /home/$username/.ssh/authorized_keys
		[ $? -eq 0 ] && echo "User SSH key been added to system!" || echo "Could not add SSH key for user!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi

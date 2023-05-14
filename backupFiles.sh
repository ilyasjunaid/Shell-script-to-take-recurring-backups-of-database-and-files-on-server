#!/bin/bash

# What to backup. 
backup_files=~/public_html

# Where to backup to.
dest=~/public_html/backups/files

# Create archive filename.
#day=$(date +%A)
#hostname=$(hostname -s)
DATE=`date +'%m-%d-%Y-%H%M'`
archive_file="$DATE.tgz"

#-------------------Deletion Settings-------------------#

# delete old files?
DELETE=y

# how many days of backups do you want to keep?
DAYS=14

#-------------------Deletion Settings-------------------#

# Print start status message.
echo "Backing up $backup_files to $dest/$archive_file"
date
echo

# Backup the files using tar.
tar czf $dest/$archive_file $backup_files --exclude='backups'

SKIPFILE=y
if  [ $DELETE = "y" ]; then
	OLD=`cd $dest; find . -name "*.tgz" -mtime +$DAYS -exec ls -1t "{}" +`;
	cd $dest; for file in $OLD;
	do
	    if  [ $SKIPFILE = "n" ]; then
	      rm ${file}; 
	    fi
	    SKIPFILE=n;
	done
	if  [ $DAYS = "1" ]; then
		echo "Yesterday's backup has been deleted."
	else
		echo "The backups from $DAYS days ago and earlier have been deleted."
	fi
fi

# Print end status message.
echo
echo "Backup finished"
date
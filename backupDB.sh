#!/bin/sh

# your MySQL server's name
SERVER="localhost"

# directory to backup to
BACKDIR=~/public_html/backups/mysql

# date format that is appended to filename
DATE=`date +'%m-%d-%Y-%H%M'`

#----------------------MySQL Settings--------------------#

# your MySQL server's location (IP address is best)
HOST="localhost"
PORT=3306

# MySQL username
USER="dbUser"

# MySQL password
PASS="dbPass"

# List all of the MySQL databases that you want to backup in here, 
# each separated by a space DBS="db1 db2"
DBS="dbName"

#TABLES=""
#TABLES="--tables registration"

# set to 'y' if you want to backup all your databases. this will override
# the database selection above.
DUMPALL=n


#----------------------Mail Settings--------------------#

# set to 'y' if you'd like to be emailed the backup (requires mutt)
MAIL=n

# email addresses to send backups to, separated by a space
EMAILS="junaid.ilyas@app-desk.com"

SUBJECT="MySQL backup on $SERVER ($DATE)"

#----------------------FTP Settings--------------------#

# set "FTP=y" if you want to enable FTP backups
FTP=n

# FTP server settings; group each remote server using arrays
# you can have unlimited remote FTP servers
FTPHOST[0]="dev.skyordering.us"
FTPUSER[0]="devskyordering"
FTPPASS[0]=""

# directory to backup to; if it doesn't exist, file will be uploaded to 
# first logged-in directory; the array indices correspond to the FTP info above
FTPDIR[0]="backups/mysql/full"

# set "DELETELOCAL=y" if you want to delete local files after transmitting them to ftp server
# DELETELOCAL works only if FTP=y
# if DELETE=y it will be created empty file after deleting with the same name 
# to deleting old files has worked correctly

DELETELOCAL=n

#-------------------Deletion Settings-------------------#

# delete old files?
DELETE=y

# how many days of backups do you want to keep?
DAYS=14

#----------------------End of Settings------------------#
# check of the backup directory exists
# if not, create it
if  [ ! -d $BACKDIR ]; then
	echo -n "Creating $BACKDIR..."
	mkdir -p $BACKDIR
	echo "done!"
fi

if  [ $DUMPALL = "y" ]; then
	echo -n "Creating list of all your databases..."
	DBS=`mysql -h $HOST --user=$USER --password=$PASS -Bse "show databases;"`
	echo "done!"
fi

echo "Backing up MySQL databases..."
for database in $DBS
do
	echo -n "Backing up database $database..."
	mysqldump --no-tablespaces -h $HOST --user=$USER --password=$PASS $database $TABLES | gzip -f -9 > "$BACKDIR/$database-$DATE-mysqlbackup.sql.gz"	
	echo "done!"
done

# if you have the mail program 'mutt' installed on
# your server, this script will have mutt attach the backup
# and send it to the email addresses in $EMAILS

if  [ $MAIL = "y" ]; then
	BODY="Your backup is ready! Find more useful scripts and info at http://www.ameir.net"
	ATTACH=`for file in $BACKDIR/*$DATE-mysqlbackup.sql.gz; do echo -n "-a ${file} ";  done`

	echo "$BODY" | mutt -s "$SUBJECT" $EMAILS $ATTACH
	if [[ $? -ne 0 ]]; then 
		echo -e "ERROR:  Your backup could not be emailed to you! \n"; 
	else
		echo -e "Your backup has been emailed to you! \n"
	fi
fi

if  [ $FTP = "y" ]; then
	echo "Initiating FTP connection..."
	if  [ $DELETE = "y" ]; then
		OLDDBS=`cd $BACKDIR; find . -name "*-mysqlbackup.sql.gz" -mtime +$DAYS`
		REMOVE=`for file in $OLDDBS; do echo -n -e "delete ${file}\n"; done`
	fi

	cd $BACKDIR
	ATTACH=`for file in *$DATE-mysqlbackup.sql.gz; do echo -n -e "put ${file}\n"; done`

for KEY in "${!FTPHOST[@]}"
do
	echo -e "\nConnecting to ${FTPHOST[$KEY]} with user ${FTPUSER[$KEY]}..."
	ftp -nv <<EOF
	open ${FTPHOST[$KEY]}
	user ${FTPUSER[$KEY]} ${FTPPASS[$KEY]}
	binary
	tick
	cd ${FTPDIR[$KEY]}
	$REMOVE
	$ATTACH
	quit
EOF
done

	if [ $DELETELOCAL = "y" ]; then
		for file in *$DATE-mysqlbackup.sql.gz
		do
			rm -f ${file}
			if  [ $DELETE = "y" ]; then
				touch ${file}
			fi
		done
	fi
	
	echo -e  "FTP transfer complete! \n"
	
fi

SKIPFILE=y
if  [ $DELETE = "y" ]; then
	OLDDBS=`cd $BACKDIR; find . -name "*-mysqlbackup.sql.gz" -mtime +$DAYS -exec ls -1t "{}" +`;
	cd $BACKDIR; for file in $OLDDBS;
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

echo "Your backup is complete!"

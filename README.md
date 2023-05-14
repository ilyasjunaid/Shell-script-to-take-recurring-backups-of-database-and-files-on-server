# Shell script to take recurring backup of database every 14 days

1- Create backups directory inside root directory and upload "backupDB.sh" to it.

2- Create mysql directory inside backups directory, the backups will be uploaded to this directory when the script runs.

3- Open this file and replace "dbUser" with your db user name, "dbPass" with your db password and "dbName" with your db name.

4- Open terminal and run this command "chmod +x path/to/file" to give permission this file to be executable.

5- Open terminal in your cpanel and run this command "bash path/to/file" to validate if the script is creating backup properly. If this command works perfectly, you will be able to see the backup created inside backup/mysql directory.

6- Write a cron job in your cpanel to run this script every 14 days. Command will be bash /home/youraccount/public_html/backups/backupDB.sh

# Shell script to take recurring backup of files every 14 days

1- Create backups directory if you have not created it already inside root directory and upload "backupFiles.sh" to it.

2- Create files directory inside backups directory, the backups will be uploaded to this directory when the script runs.

3- Open terminal and run this command "chmod +x path/to/file" to give permission to this file to be executable.

4- Open terminal in your cpanel and run this command "bash path/to/file" to validate if the script is creating backup properly. If this command works perfectly, you will be able to see the backup created inside backup/files directory.

5- Write a cron job in your cpanel to run this script every 14 days. Command will be bash /home/youraccount/public_html/backups/backupFiles.sh

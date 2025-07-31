#!/bin/bash
source ./common.sh
check_root
echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing my sql server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabling mysqld"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "starting mysqld"
mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "setting the password"
print_time

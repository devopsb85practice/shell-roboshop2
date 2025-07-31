#!/bin/bash
source ./common.sh
app_name=shipping
check_root
echo "please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD
app_setup
maven_setup
systemd_setup
dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "installing my sql"
mysql -h mysql.prasannadevops.online -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities'
if [ $? -ne 0 ]
then
    mysql -h mysql.prasannadevops.online -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    VALIDATE $? "loading the schema"
    mysql -h mysql.prasannadevops.online -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
    VALIDATE $? "creating user"
    mysql -h mysql.prasannadevops.online -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "loading the master data"
else 
    echo "data already loaded into mysql ....$G skipping $N"
fi
systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "restarting shipping service"
print_time
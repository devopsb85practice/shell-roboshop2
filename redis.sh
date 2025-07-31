#!/bin/bash
source ./common.sh
app_name=redis
check_root
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling the default redis version"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling the redis 7 version"
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "updating the listen address"
sed -i '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "updating protected mode"
systemctl enable redis &>>$LOG_FILE
VALIDATE $? "enabling redis"
systemctl start redis &>>$LOG_FILE
VALIDATE $? "starting the redis server"
print_time


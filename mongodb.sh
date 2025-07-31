#!/bin/bash
source ./common.sh
app_name=mongodb
check_root
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying the repo file" 
dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongodb"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongodb"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "editing mongo.conf file" 
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb"
print_time

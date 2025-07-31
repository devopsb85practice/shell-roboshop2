#!/bin/bash
source ./common.sh
check_root
echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD
cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copying the repo file"
dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing the rabbitmq server"
systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enabling rabbitmq server"
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "starting rabbitmq server"
rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE
VALIDATE $? "adding the user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "setting the permissions to the user"


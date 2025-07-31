#!/bin/bash
source ./common.sh
app_name=nginx
check_root
dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling nginx"
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx 24 version"
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx"
systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enabling nginx service"
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "starting nginx"
rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing the default files"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading the frontend.zip file"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping the files"
rm -rf /etc/nginx/nginx.conf
VALIDATE $? "replacing the nginx confifuration file"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "copying the nginx configuration file to the location"
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restarting the nginx"
print_time



#!/bin/bash
START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="/$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at $(date)"| tee -a $LOG_FILE
check_root(){
    if [ "$USERID" -ne 0 ]
    then   
        echo -e "$R you are not running with root access, please run with root access $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G you are running with root access $N" | tee -a $LOG_FILE
    fi
}
VALIDATE(){
    if [ "$1" -eq 0 ]
    then
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is $R failure $N" | tee -a $LOG_FILE
        exit 1
    fi
}
app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "creating user roboshop"
    else
        echo "User roboshop already exists  $Y SKIPPING $N"
    fi
    mkdir /app 
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "downloading the $app_name.zip"
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipping the files"
}
print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "script executed successfully, total time taken is $G $TOTAL_TIME seconds $N"
}
nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling nodejs"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs"
    npm install &>>$LOG_FILE
    VALIDATE $? "installing dependencies"
    
}
python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "installing python3"
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "creating user roboshop"
    else
        echo "user already exists"
    fi  
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}
maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "installing maven " &>>$LOG_FILE
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "creating user roboshop"
    else
        echo "user already exists"
    fi 
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "cleaning package"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "moving the file"
}
systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "daemon reloading the service"
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "enabling $app_name"
    systemctl start $app_name&>>$LOG_FILE
    VALIDATE $? "starting the $app_name service"
}

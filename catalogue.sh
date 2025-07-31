source ./common.sh
app_name =catalogue
check_root
app_setup
nodejs_setup
systemd_setup



cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying the mongo repo file"
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing the mongodb client"
STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi
print_time

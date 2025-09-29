#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"  #all logs will come usder Shell-roboshop
SCRIPT_NAME=$( echo $0 | cut -d "." -f2 ) # to get only user
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
echo "script start time = $(date)"

if [ $USERID -ne 0 ]; then
    echo -e "ERROR:: please user must use $R Root privilages $N" 
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo " $2 was failed" 
        exit 1
    else
        echo "$2 was successful" 
    fi
    
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable of nodejs"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable of nodejs"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Istallation of nodejs"


id roboshop
if [ $? -ne 0 ]; then &>>$LOG_FILE
    echo -e "$G user was not created $N"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "roboshop user"
else
    echo -e "$R user already created $N"
fi

mkdir -p /app 
VALIDATE $? "app directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "download user application"

cd /app 
rm -rf /app/* &>>$LOG_FILE              #it will remove the code in app if we run the script multiple times
VALIDATE $? "rmoving of old code if exist"
unzip /tmp/user.zip
npm install &>>$LOG_FILE
cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-reload"
systemctl enable user &>>$LOG_FILE
VALIDATE $? "enable user"
systemctl start user &>>$LOG_FILE
VALIDATE $? "user start"
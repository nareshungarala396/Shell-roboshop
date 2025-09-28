#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f2 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script exicution started:: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then 
    echo -e "ERROR : $R use root user privilages $N"
    exit 1
fi

VALIDATE(){

    if [ $1 -ne 0 ]; then 
        echo -e "$2 has been $R failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G successful $N" | tee -a $LOG_FILE
    fi
}


cp mongodb.repo /etc/yum.repos.d/mongodb.repo        #it will copy repo into required file for proceeding for ista.
VALIDATE $? "MONGODB REPO"
dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "MAONGODB INSTALL"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "SEVICE ENABLE"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "SERVICE START mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to mongodb"

systemctl restart mongod &>>$LOG_FILE

VALIDATE $? "Restart mongodb"




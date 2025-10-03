#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SCRIPT_DIR=$PWD
echo "script exicution date :: $(date)"
SCRIPT_NAME=$(echo $0 | cut -d "." -f2)
LOGS_FOLDER="/var/log/Shell-roboshop"
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p LOGS_FOLDER

if [ $USERID -ne 0 ]; then
    echo -e "Please use root user Privilages $R ERROR $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e "$2 has been $R failed $N"
    else
    echo -e "$2 has been  $g successful $N"
    fi
}

dnf module disable nodejs -y

VALIDATE $? "DISABLING NODEJS"

dnf module enable nodejs:20 -y

VALIDATE $? "ENABLING NODEJS"

dnf install nodejs -y

VALIDATE $? "INSTALING NODEJS"

id roboshop
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        echo "$G roboshop user has been created successfully $N"
    else
        echo "$G roboshop user already created successfully $N"
    fi

mkdir /app 

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
cd /app 

rm -rf /app/*

VALIDATE $? "existing content removed successfully"

unzip /tmp/cart.zip

VALIDATE $? "INSTALING NODEJS"

npm install 

VALIDATE $? "INSTALING npm"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service

systemctl daemon-reload

VALIDATE $? "daemon-reload"

systemctl enable cart 

VALIDATE $? "enable cart "

systemctl start cart

VALIDATE $? "start cart"


USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/Shell-roboshop"  #all logs will come usder Shell-roboshop
SCRIPT_NAME=$( echo $0 | cut -d "." -f2 ) # to get only cart
SCRIPT_DIR=$PWD
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
echo "script start time = $(date)"

mkdir -p $LOGS_FOLDER

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

##### NodeJS ####
dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzip cart"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enable cart"

systemctl restart cart
VALIDATE $? "Restarted cart"


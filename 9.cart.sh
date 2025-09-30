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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart application"

cd /app 
rm -rf /app/* &>>$LOG_FILE

unzip /tmp/cart.zip

npm install &>>$LOG_FILE
cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "daemon-reload"

systemctl enable catr &>>$LOG_FILE
VALIDATE $? "enable cart"
systemctl restart cart &>>$LOG_FILE




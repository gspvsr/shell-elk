#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" >> "$LOGFILE"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILED $N"
        exit 1
    else 
        echo -e "$2....$G SUCCESS $N"
    fi
}

USERID=$(id -u)

if [ $USERID -ne 0 ]
then
    echo "ERROR :: Please install with Root Access"
    exit 1
else
    echo "you are root user"
fi 

yum install java-11-openjdk-devel -y >> "$LOGFILE" 2>> "$LOGFILE"
VALIDATE $? "Installing the Java-11 Open JDK Package"

cp elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo >> "$LOGFILE" 2>> "$LOGFILE"
VALIDATE $? "Copying the elasticsearch.repo"

cp elasticsearch.yml /etc/elasticsearch/
VALIDATE $? "Configuring the elasticsearch.yaml"

yum install elasticsearch -y >> "$LOGFILE" 2>> "$LOGFILE"
VALIDATE $? "Installing Elasticsearch"

systemctl restart elasticsearch >> "$LOGFILE" 2>> "$LOGFILE"
VALIDATE $? "Restarting Elasticsearch"

systemctl enable elasticsearch >> "$LOGFILE" 2>> "$LOGFILE"
VALIDATE $? "Enabling Elasticsearch"

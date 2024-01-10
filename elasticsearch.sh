#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
ELASTICSEARCH_CONFIG="/etc/elasticsearch/elasticsearch.yml"

log() {
    echo -e "$1" >> "$LOGFILE"
}

validate() {
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILED $N"
        exit 1
    else
        echo -e "$2....$G SUCCESS $N"
    fi
}

log "Script started executing at $TIMESTAMP"

# Check if run as root
USERID=$(id -u)
if [ $USERID -ne 0 ]; then
    log "ERROR :: Please run with Root Access"
    exit 1
else
    log "You are root user"
fi

# Install Java 11 OpenJDK
yum install java-11-openjdk-devel -y >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Installing the Java-11 Open JDK Package"

# Copy elasticsearch.repo
cp elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Copying the elasticsearch.repo"

# Install Elasticsearch
yum install elasticsearch -y >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Installing Elasticsearch"

# Uncomment http.port: 9200
sed -i -e 's/^#http\.port: 9200/http.port: 9200/' "$ELASTICSEARCH_CONFIG" >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Uncommenting http.port"

# Change the default network host
sed -i -e 's/^#network\.host: .*/network.host: 0.0.0.0/' "$ELASTICSEARCH_CONFIG" >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Changing the default network host"

# Add a line under the Bootstrap section (second row)
sed -i -e '/^#bootstrap\./a\bootstrap.type: single-node' "$ELASTICSEARCH_CONFIG" >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Add a line under the Bootstrap section"

# Restart Elasticsearch
systemctl restart elasticsearch >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Restarting Elasticsearch"

# Enable Elasticsearch
systemctl enable elasticsearch >> "$LOGFILE" 2>> "$LOGFILE"
validate $? "Enabling Elasticsearch"

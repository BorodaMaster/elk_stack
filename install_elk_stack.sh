#!/bin/bash

check_error() {
   if [[ ${1} -ne 0 ]]; then
       echo "${2}, Error code ${1}"
       exit ${1};
   fi
}

elk_services() {
    sudo systemctl $1 kibana.service
    sudo systemctl $1 logstash.service
    sudo systemctl $1 elasticsearch.service
} 

path_elasticsearch="/usr/share/elasticsearch"
path_logstash="/usr/share/logstash"
path_kibana="/usr/share/kibana"

# Update system
sudo yum -y update

# OpenJDK Installation
java_version=$(java -version 2>&1 | egrep 'version' | egrep -o '([0-9]\.){2}[0-9]')

if [ -z  $java_version ]; then
    echo "JAVA not installed, OpenJDK installing ..."
    sudo yum -y install java-1.8.0-openjdk
    check_error $? "[ ERROR ] - Unable to install rpm package java-1.8.0-openjdk"
elif [  "$java_version" == "1.8.0" ]; then
    echo "Current version JAVA is $java_version"
else
    echo "Wrong the version JAVA, delete before starting script again ..."
    exit 1;
fi

# Add GPG-Key
sudo rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
check_error $? "[ ERROR ] - Cannot import GPG-Key"

# Copy repo
yes | sudo cp /tmp/elk_stack/elk_repo/kibana.repo /etc/yum.repos.d/ELK-Kibana.repo
check_error $? "[ ERROR ] - Cannot copy file kibana.repo"
yes | sudo cp /tmp/elk_stack/elk_repo/logstash.repo /etc/yum.repos.d/ELK-Logstash.repo
check_error $? "[ ERROR ] - Cannot copy file logstash.repo"
yes | sudo cp /tmp/elk_stack/elk_repo/elasticsearch.repo /etc/yum.repos.d/ELK-Elasticsearch.repo
check_error $? "[ ERROR ] - Cannot copy file elasticsearch.repo"

# Update system after copy repo
sudo yum -y update

# ELK Stack Installation

if [ -d "$path_elasticsearch" ]; then
    echo "Elasticsearch installed"
else
    echo "Elasticsearch installing ..."
    sudo yum -y install elasticsearch
    check_error $? "[ ERROR ] - Unable to install rpm package elasticsearch"
fi

if [ -d "$path_kibana" ]; then
    echo "Kibana installed"
else
    echo "Kibana installing ..."
    sudo yum -y install kibana
    check_error $? "[ ERROR ] - Unable to install rpm package kibana"
    sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
    check_error $? "[ ERROR ] - Cannot change config file kibana.yml"
fi

if [ -d "$path_logstash" ]; then
    echo "Logstash installed"
else
    echo "Logstash installing ..."
    sudo yum -y install logstash
    check_error $? "[ ERROR ] - Unable to install rpm package logstash"
    yes | sudo cp /tmp/elk_stack/elk_conf/10-syslog.conf /etc/logstash/conf.d/
    check_error $? "[ ERROR ] - Cannot copy file 10-syslog.conf"
fi

# Enable boot services
elk_services enable

# Start services
elk_services start

#!/bin/bash

path_elasticsearch="/usr/share/elasticsearch"
path_logstash="/usr/share/logstash"
path_kibana="/usr/share/kibana"

# Update system
#sudo yum -y update

# OpenJDK Installation
java_version=$(java -version 2>&1 | egrep 'version' | egrep -o '([0-9]\.){2}[0-9]')

if [ -z  $java_version ]; then
    echo "JAVA not installed, OpenJDK installing ..."
    #sudo yum -y install java-1.8.0-openjdk
elif [  $java_version == '1.8.0' ]; then
    echo "Current version JAVA is $java_version"
else
    echo "Wrong the version JAVA, delete before starting script again ..."
fi

# Add GPG-Key
#sudo rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch

# Copy repo
#yes | sudo cp /tmp/elk_repo/kibana.repo /etc/yum.repos.d/ELK-Kibana.repo
#yes | sudo cp /tmp/elk_repo/logstash.repo /etc/yum.repos.d/ELK-Logstash.repo
#yes | sudo cp /tmp/elk_repo/elasticsearch.repo /etc/yum.repos.d/ELK-Elasticsearch.repo

# Update system after copy repo
#sudo yum -y update

# ELK Stack Installation

if [ ! -f $path_elasticsearch ]; then
    echo "Elasticsearch installed"
else
    echo "Elasticsearch installing ..."
    #sudo yum -y install elasticsearch
fi

if [ ! -f $path_kibana ]; then
    echo "Kibana installed"
else
    echo "Kibana installing ..."
    #sudo yum -y install kibana
    #sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
fi

if [ ! -f $path_logstash ]; then
    echo "Logstash installed"
else
    echo "Logstash installing ..."
    #sudo yum -y install logstash
    #yes | sudo cp /tmp/elk_conf/10-syslog.conf /etc/logstash/conf.d/
fi

# Enable boot services
#sudo systemctl enable kibana.service
#sudo systemctl enable logstash.service
#sudo systemctl enable elasticsearch.service

# Start services
#sudo systemctl start kibana.service
#sudo systemctl start logstash.service
#sudo systemctl start elasticsearch.service

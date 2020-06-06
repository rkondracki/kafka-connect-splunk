#!/bin/bash

# Checkout, build and run kafka-connect-splunk in the fight

curdir=`pwd`
git clone https://github.com/splunk/kafka-connect-splunk.git

branch=${KAFKA_CONNECT_BRANCH:-develop}
# build the package
cd kafka-connect-splunk && git checkout ${branch} && bash build.sh
cd /kafka-connect
cp kafka-connect-splunk/target/splunk-kafka-connect-v*.jar /kafka-connect/
echo "plugin.path=/kafka-connect" >> /kafka-connect/kafka/config/connect-distributed.properties

debug=${KAFKA_CONNECT_LOGGING:-DEBUG}
echo "log4j.logger.com.splunk=${debug}" >> config/connect-log4j.properties

cd kafka

echo "Start ZooKeeper"
bin/zookeeper-server-start.sh config/zookeeper.properties > /kafka-connect/logs/zookeeper.txt 2>&1 &

echo "Start kafka server"
bin/kafka-server-start.sh config/server.properties > /kafka-connect/logs/kafka.txt 2>&1 &

echo "Run connect"
./bin/connect-distributed.sh config/connect-distributed.properties > /kafka-connect/logs/kafka_connect.txt

#!/bin/sh

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic

if ! grep -q "^############ Settings Added By Docker ############$" $KAFKA_HOME/config/server.properties; then
    echo -e "\n" >> $KAFKA_HOME/config/server.properties
    echo "############ Settings Added By Docker ############" >> $KAFKA_HOME/config/server.properties
    echo -e "\n" >> $KAFKA_HOME/config/server.properties
fi

# Set the external host and port
if [ ! -z "$ADVERTISED_HOST" ]; then
    echo "advertised listeners: $ADVERTISED_HOST"
    if grep -q "^advertised.listeners" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(advertised.listeners)=(.*)/\1=$ADVERTISED_HOST/g" $KAFKA_HOME/config/server.properties
    else
        echo "advertised.listeners=$ADVERTISED_HOST" >> $KAFKA_HOME/config/server.properties
    fi
fi

if [ ! -z "$ADVERTISED_PORT" ]; then
    echo "listeners: $ADVERTISED_PORT"
    if grep -q "^listeners" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(listeners)=(.*)/\1=$ADVERTISED_PORT/g" $KAFKA_HOME/config/server.properties
    else
        echo "listeners=$ADVERTISED_PORT" >> $KAFKA_HOME/config/server.properties
    fi
fi

# Set the zookeeper chroot
if [ ! -z "$ZK_CHROOT" ]; then
    # wait for zookeeper to start up
    until zkServer.sh status; do
      sleep 0.1
    done

    # create the chroot node
    echo "create /$ZK_CHROOT \"\"" | zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\1=localhost:2181\/$ZK_CHROOT/g" $KAFKA_HOME/config/server.properties
fi

# Allow specification of log retention policies
if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

# Configure the default number of log partitions per topic
if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

# Enable/disable auto creation of topics
if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

# Run Kafka
export JMX_PORT=9999
kafka-server-start.sh $KAFKA_HOME/config/server.properties

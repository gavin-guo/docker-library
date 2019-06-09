#!/bin/sh

while ! nc -vz localhost 2181; do   
    sleep 0.1
done

echo -e "\n" >> $KAFKA_HOME/config/server.properties

sed -r -i "s/#(listeners)=(.*)/\1=PLAINTEXT:\/\/0.0.0.0:9092/g" $KAFKA_HOME/config/server.properties

if [ ! -z "$ADVERTISED_LISTENERS" ]; then
    echo "advertised.listeners: $ADVERTISED_LISTENERS"
    if grep -q "^#advertised.listeners" $KAFKA_HOME/config/server.properties; then
        sed -r -i "s/#(advertised.listeners)=(.*)/\1=PLAINTEXT:\/\/$ADVERTISED_LISTENERS/g" $KAFKA_HOME/config/server.properties
    else
        echo "advertised.listeners=PLAINTEXT://$ADVERTISED_LISTENERS" >> $KAFKA_HOME/config/server.properties
    fi
fi

if [ ! -z "$LOG_RETENTION_HOURS" ]; then
    echo "log retention hours: $LOG_RETENTION_HOURS"
    sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi
if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$NUM_PARTITIONS" ]; then
    echo "default number of partition: $NUM_PARTITIONS"
    sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$AUTO_CREATE_TOPICS" ]; then
    echo "auto.create.topics.enable: $AUTO_CREATE_TOPICS"
    echo "auto.create.topics.enable=$AUTO_CREATE_TOPICS" >> $KAFKA_HOME/config/server.properties
fi

export JMX_PORT=9999
kafka-server-start.sh $KAFKA_HOME/config/server.properties

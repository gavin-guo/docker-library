#!/bin/bash
set -e

# for zookeeper
if [[ ! -f "$ZOO_CONF_DIR/zoo.cfg" ]]; then
  CONFIG="$ZOO_CONF_DIR/zoo.cfg"

  echo "clientPort=$ZOO_PORT" >>"$CONFIG"
  echo "dataDir=$ZOO_DATA_DIR" >>"$CONFIG"
  echo "dataLogDir=$ZOO_DATA_LOG_DIR" >>"$CONFIG"

  echo "tickTime=$ZOO_TICK_TIME" >>"$CONFIG"
  echo "initLimit=$ZOO_INIT_LIMIT" >>"$CONFIG"
  echo "syncLimit=$ZOO_SYNC_LIMIT" >>"$CONFIG"

  echo "autopurge.snapRetainCount=$ZOO_AUTOPURGE_SNAPRETAINCOUNT" >>"$CONFIG"
  echo "autopurge.purgeInterval=$ZOO_AUTOPURGE_PURGEINTERVAL" >>"$CONFIG"
  echo "maxClientCnxns=$ZOO_MAX_CLIENT_CNXNS" >>"$CONFIG"
fi

if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
  echo "${ZOO_MY_ID:-1}" >"$ZOO_DATA_DIR/myid"
fi

# for kafka
sed -r -i "s/#(listeners)=(.*)/\1=PLAINTEXT:\/\/0.0.0.0:$KAFKA_PORT/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/#(advertised.listeners)=(.*)/\1=PLAINTEXT:\/\/localhost:$KAFKA_PORT/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/(zookeeper.connect)=(.*)/\1=127.0.0.1:$ZOO_PORT/g" $KAFKA_HOME/config/server.properties
sed -r -i "s/(log.dirs)=(.*)/\1=${KAFKA_LOG_DIR//\//\\/}/g" $KAFKA_HOME/config/server.properties

if [ ! -z "$LOG_RETENTION_HOURS" ]; then
  echo "log.retention.hours: $LOG_RETENTION_HOURS"
  sed -r -i "s/(log.retention.hours)=(.*)/\1=$LOG_RETENTION_HOURS/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$LOG_RETENTION_BYTES" ]; then
  echo "log.retention.bytes: $LOG_RETENTION_BYTES"
  sed -r -i "s/#(log.retention.bytes)=(.*)/\1=$LOG_RETENTION_BYTES/g" $KAFKA_HOME/config/server.properties
fi

if [ ! -z "$NUM_PARTITIONS" ]; then
  echo "num.partitions: $NUM_PARTITIONS"
  sed -r -i "s/(num.partitions)=(.*)/\1=$NUM_PARTITIONS/g" $KAFKA_HOME/config/server.properties
fi

/usr/bin/supervisord --nodaemon --configuration /supervisord.conf

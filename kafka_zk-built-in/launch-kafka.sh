#!/bin/bash

set -e

while ! nc -vz 127.0.0.1 $ZOO_PORT; do
  sleep 2
done

export JMX_PORT=9999
kafka-server-start.sh $KAFKA_HOME/config/server.properties

#!/bin/sh
if [ -z "$ELASTICSEARCH_CONNECT" ]; then
    echo "ERROR: missing mandatory config: ELASTICSEARCH_CONNECT"
    exit 1
else
    sed -r -i "s/(hosts:) (.*)/\1 [\"$ELASTICSEARCH_CONNECT\"]/g" /filebeat.yml
fi

if [ ! -z "$HOSTNAME" ]; then
    sed -r -i "s/(hostname:) (.*)/\1 $HOSTNAME/g" /filebeat.yml
fi

/filebeat/filebeat -e -c /filebeat.yml
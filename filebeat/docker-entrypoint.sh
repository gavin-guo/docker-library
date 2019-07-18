#!/bin/sh
if [ -z "$ELASTICSEARCH_ENDPOINT" ]; then
    echo "ERROR: missing mandatory config: ELASTICSEARCH_ENDPOINT"
    exit 1
else
    sed -r -i "s/(hosts:) (.*)/\1 [$ELASTICSEARCH_ENDPOINT]/g" /filebeat.yml
fi

if [ ! -z "$HOSTNAME" ]; then
    sed -r -i "s/(hostname:) (.*)/\1 $HOSTNAME/g" /filebeat.yml
fi

if [ ! -z "$INDEX_NAME" ]; then
    sed -r -i "s/(index:) (.*)/\1 \"$INDEX_NAME\"/g" /filebeat.yml
fi

if [ ! -z "$USER_NAME" ]; then
    echo "  username: \"$USER_NAME\"" >> /filebeat.yml
fi

if [ ! -z "$PASSWORD" ]; then
	echo "  password: \"$PASSWORD\"" >> /filebeat.yml
fi

/filebeat/filebeat -e -c /filebeat.yml

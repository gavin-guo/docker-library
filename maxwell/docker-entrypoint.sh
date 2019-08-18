#!/bin/sh

if [ ! -z "$MYSQL_HOST" ]; then
    sed -r -i "s/(host)=(.*)/\1=$MYSQL_HOST/g" /config/config.properties
fi

if [ ! -z "$MYSQL_PORT" ]; then
    sed -r -i "s/(port)=(.*)/\1=$MYSQL_PORT/g" /config/config.properties
fi

if [ ! -z "$MYSQL_USER" ]; then
    sed -r -i "s/(user)=(.*)/\1=$MYSQL_USER/g" /config/config.properties
fi

if [ ! -z "$MYSQL_PASSWORD" ]; then
    sed -r -i "s/(password)=(.*)/\1=$MYSQL_PASSWORD/g" /config/config.properties
fi

if [ ! -z "$INCLUDE_DBS" ]; then
    sed -r -i "s/(include_dbs)=(.*)/\1=$INCLUDE_DBS/g" /config/config.properties
fi

if [ ! -z "$INCLUDE_TABLES" ]; then
    sed -r -i "s/(include_tables)=(.*)/\1=$INCLUDE_TABLES/g" /config/config.properties
fi

if [ ! -z "$KAFKA_BOOTSTRAP_SERVERS" ]; then
    sed -r -i "s/(kafka.bootstrap.servers)=(.*)/\1=$KAFKA_BOOTSTRAP_SERVERS/g" /config/config.properties
fi

if [ ! -z "$IGNORE_PRODUCER_ERROR" ]; then
    sed -r -i "s/(ignore_producer_error)=(.*)/\1=$IGNORE_PRODUCER_ERROR/g" /config/config.properties
fi

/maxwell/bin/maxwell --config /config/config.properties
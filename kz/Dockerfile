FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

# install required packages
RUN apk add --no-cache \
    bash \
    su-exec \
    supervisor \
    snappy

ENV ZOO_USER=zookeeper \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2

ENV SCALA_VERSION=2.11 \
    KAFKA_VERSION=0.9.0.1 \
    ZOOKEEPER_VERSION=3.4.10

ENV KAFKA_HOME="/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" \
    ZOOKEEPER_HOME="/zookeeper-${ZOOKEEPER_VERSION}"

# Add a user and make dirs
RUN set -x \
    && adduser -D "$ZOO_USER" \
    && mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" \
    && chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR"

# Download Zookeeper & Kafka & Kafdrop & Kafka-Manager, untar and clean up
RUN set -x \
	&& apk update \
    && apk add --no-cache --virtual .build-deps \
    	ca-certificates \
    	wget \
        tar \
    && wget -q "https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
    && tar -xzf "zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
    && cp "$ZOOKEEPER_HOME/conf/zoo_sample.cfg" "$ZOOKEEPER_HOME/conf/zoo.cfg" \
    && wget -q "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && rm -r "zookeeper-${ZOOKEEPER_VERSION}.tar.gz" "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && apk del .build-deps

ADD scripts/start-kafka.sh /

COPY supervisord.conf /supervisord.conf

RUN set -x \
    && chmod +x /start-kafka.sh

VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR"]

ENV PATH=$PATH:${ZOOKEEPER_HOME}/bin:$KAFKA_HOME/bin

# $ZOO_PORT is zookeeper, 9092 is kafka, 9000 is kafdrop, $KAFKA_MONITOR_PORT is Kafka-offset-monitor
EXPOSE 2181 9092

ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/supervisord.conf"]
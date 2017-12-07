FROM openjdk:8-jre-alpine

MAINTAINER gavin-guo

# Install required packages
RUN apk add --no-cache \
    bash \
    su-exec \
    supervisor

ENV ZOO_USER=zookeeper \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2

ENV SCALA_VERSION=2.11 \
    KAFKA_VERSION=0.11.0.1 \
    ZOOKEEPER_VERSION=3.4.10 \
    KAFDROP_VERSION=2.0.0 \
    KAFKA_MANAGER_VERSION=1.3.3.7

ENV KAFKA_HOME="/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" \
    ZOOKEEPER_HOME="/zookeeper-${ZOOKEEPER_VERSION}"

ENV KAFKA_MONITOR_PORT 8081

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
    && wget -q "http://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
    && tar -xzf "zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
    && cp "$ZOOKEEPER_HOME/conf/zoo_sample.cfg" "$ZOOKEEPER_HOME/conf/zoo.cfg" \
    && wget -q "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && wget -q "http://sftp.chinacloudapp.cn/docker/kafdrop-${KAFDROP_VERSION}.jar" -O /kafdrop.jar \
    && wget -q "https://github.com/Morningstar/kafka-offset-monitor/releases/download/0.4.1/KafkaOffsetMonitor-assembly-0.4.1-SNAPSHOT.jar" -O /kafkaOffsetMonitor.jar \
    && rm -r "zookeeper-${ZOOKEEPER_VERSION}.tar.gz" "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && apk del .build-deps

ADD scripts/start-kafka.sh scripts/start-kafdrop.sh scripts/start-kafka-offset-monitor.sh /

COPY supervisord.conf /supervisord.conf

RUN set -x \
    && chmod +x /start-kafka.sh /start-kafdrop.sh /start-kafka-offset-monitor.sh

VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR"]

ENV PATH=$PATH:${ZOOKEEPER_HOME}/bin:$KAFKA_HOME/bin:$KAFKA_MANAGER_HOME/bin \
    ZOOCFGDIR=${ZOOKEEPER_HOME}/conf

# $ZOO_PORT is zookeeper, 9092 is kafka, 9000 is kafdrop, $KAFKA_MONITOR_PORT is Kafka-offset-monitor
EXPOSE $ZOO_PORT 9092 9000 $KAFKA_MONITOR_PORT

ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/supervisord.conf"]
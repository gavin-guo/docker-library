FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash \
    supervisor \
    snappy

ENV SCALA_VERSION=2.11 \
    KAFKA_VERSION=1.0.0 \
    KAFDROP_VERSION=2.0.0 \
    KAFKA_HOME="/kafka"

RUN set -x \
	&& apk update \
    && apk add --no-cache --virtual .build-deps \
    	ca-certificates \
    	wget \
        tar \
    && wget -q "http://mirror.reverse.net/pub/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && mv "kafka_${SCALA_VERSION}-${KAFKA_VERSION}" "$KAFKA_HOME" \
    # && wget -q "http://sftp.chinacloudapp.cn/docker/kafdrop-${KAFDROP_VERSION}.jar" -O /kafdrop.jar \
    # && rm -r "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
    && apk del .build-deps

COPY docker-entrypoint.sh /

RUN set -x \
    && chmod +x /docker-entrypoint.sh

ENV PATH=$PATH:$KAFKA_HOME/bin

VOLUME ["/tmp/kafka-logs"]

WORKDIR $KAFKA_HOME/bin

# EXPOSE 9092 9000
EXPOSE 9092

ENTRYPOINT ["/docker-entrypoint.sh"]
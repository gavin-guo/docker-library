FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

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
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60

ENV SCALA_VERSION=2.11 \
    KAFKA_VERSION=1.0.0 \
    KAFKA_HOME="/kafka"

ARG GPG_KEY=C61B346552DC5E0CB53AA84F59147497767E7473
ARG DISTRO_NAME=zookeeper-3.4.13

RUN set -x \
    && adduser -D "$ZOO_USER" \
    && mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" \
    && chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR"

# Download Zookeeper & Kafka & Kafdrop & Kafka-Manager, untar and clean up
RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
    	ca-certificates \
        gnupg \
        libressl; \
    wget -q "https://archive.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    # wget -q "https://archive.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
    # export GNUPGHOME="$(mktemp -d)"; \
    # gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" || \
    # gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" || \
    # gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY"; \
    # gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -xzf "$DISTRO_NAME.tar.gz"; \
    # rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc"; \
    wget -q "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    mv "kafka_${SCALA_VERSION}-${KAFKA_VERSION}" "$KAFKA_HOME"; \
    apk del .build-deps

ADD ./start-kafka.sh /

COPY ./supervisord.conf /supervisord.conf

RUN set -x \
    && chmod +x /start-kafka.sh

ENV PATH=$PATH:$KAFKA_HOME/bin:/$DISTRO_NAME/bin

WORKDIR $KAFKA_HOME/bin

VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "/tmp/kafka-logs"]

EXPOSE 2181 9092

ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/supervisord.conf"]
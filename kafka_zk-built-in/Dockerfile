FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash \
    supervisor \
    snappy

ENV ZOO_USER=zookeeper \
    ZOO_HOME="/opt/zookeeper" \
    ZOO_CONF_DIR=/opt/zookeeper/conf \
    ZOO_DATA_DIR=/opt/zookeeper/data \
    ZOO_DATA_LOG_DIR=/opt/zookeeper/datalog \
    ZOO_PORT=2181 \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=0 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=60

ARG GPG_KEY=C61B346552DC5E0CB53AA84F59147497767E7473
ARG DISTRO_NAME=zookeeper-3.4.13

ENV SCALA_VERSION=2.11 \
    KAFKA_VERSION=1.0.0 \
    KAFKA_PORT=9092 \
    KAFKA_HOME="/opt/kafka" \
    KAFKA_LOG_DIR=/opt/kafka/kafka-logs

RUN set -ex; \
    mkdir /opt; \
    apk add --no-cache --virtual .build-deps \
        ca-certificates \
        gnupg \
        libressl; \
    # download zookeeper
    wget -q "https://archive.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    wget -q "https://archive.apache.org/dist/zookeeper/$DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY"; \
    gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -xzf "$DISTRO_NAME.tar.gz"; \
    mv "$DISTRO_NAME" "$ZOO_HOME"; \
    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc"; \
    # download kafka
    wget -q "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    tar -xzf "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    mv "kafka_${SCALA_VERSION}-${KAFKA_VERSION}" "$KAFKA_HOME"; \
    rm -r "kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    apk del .build-deps

RUN set -ex; \
    adduser -D "$ZOO_USER"; \
    mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"; \
    chown "$ZOO_USER:$ZOO_USER" "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR"

COPY supervisord.conf launch-kafka.sh docker-entrypoint.sh /

RUN set -x \
    && chmod +x /launch-kafka.sh \
    && chmod +x /docker-entrypoint.sh

ENV PATH=$PATH:$ZOO_HOME/bin:$KAFKA_HOME/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR

WORKDIR /

VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "$KAFKA_LOG_DIR"]

EXPOSE $ZOO_PORT $KAFKA_PORT

ENTRYPOINT ["/docker-entrypoint.sh"]
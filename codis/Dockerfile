FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash

ENV CODIS_HOME=/codis \
    PROXY_NUM=1 \
    GROUP_NUM=2 \
    SLAVE_NUM_PER_GROUP=1 \
    PRODUCT_NAME=demo \
    PRODUCT_AUTH=secret \
    SESSION_AUTH=secret \
    SENTINEL_QUORUM=2 \
    SENTINEL_DOWN_AFTER=30s

RUN set -x \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
        ca-certificates \
        wget \
        tar \
    && wget -q "http://sftp.chinacloudapp.cn/docker/codis3.2.2-go1.9.2-linux.zip" \
    && unzip codis3.2.2-go1.9.2-linux.zip \
    && mv codis3.2.2-go1.9.2-linux "$CODIS_HOME" \
    && rm -r "codis3.2.2-go1.9.2-linux.zip" \
    && apk del .build-deps

RUN set -x \
    && mkdir /log /config /data

COPY docker-entrypoint.sh /
COPY codis.json dashboard.toml proxy_sample.toml redis_sample.conf sentinel_sample.conf /config/

RUN set -x \
    && chmod +x /docker-entrypoint.sh

ENV PATH=$PATH:${CODIS_HOME}

VOLUME ["/data"]

WORKDIR $CODIS_HOME

EXPOSE 18090 19000 19001 19002

ENTRYPOINT ["/docker-entrypoint.sh"]
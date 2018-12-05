FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash

ENV FILEBEAT_VERSION=6.4.1

RUN set -x \
	&& apk update \
    && apk add --no-cache --virtual .build-deps \
    	ca-certificates \
    	wget \
        tar \
    && mkdir /filebeat \
    && wget -q "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz" -O filebeat.tar.gz \
    && tar -xf filebeat.tar.gz -C /filebeat --strip-components=1 \
    && rm -r filebeat.tar.gz \
    && apk del .build-deps

RUN set -x \
    && chmod +x /filebeat/filebeat \
	&& mkdir /input

COPY docker-entrypoint.sh filebeat.yml /

RUN set -x \
    && chmod +x /docker-entrypoint.sh

VOLUME ["/input"]

ENTRYPOINT ["/docker-entrypoint.sh"]
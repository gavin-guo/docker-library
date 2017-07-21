FROM alpine:3.6

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash \
    su-exec

ENV FILEBEAT_VERSION=5.5.0

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
	&& mkdir /input

COPY filebeat.yml /

VOLUME /input

ENV PATH=$PATH:/filebeat/bin

CMD [ “/filebeat/bin/filebeat", "-e", "-c", "/filebeat.yml" ]
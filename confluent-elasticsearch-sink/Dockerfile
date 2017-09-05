FROM openjdk:8-jre-alpine

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash \
    su-exec \
    curl

RUN set -x \
	&& apk update \
    && apk add --no-cache --virtual .build-deps \
    	ca-certificates \
    	wget \
        tar \
    && mkdir /confluent /config \
    && wget -q "http://sftp.chinacloudapp.cn/docker/confluent-oss-3.3.0-2.11.tar.gz" -O /confluent.tar.gz \
    && tar -xf confluent.tar.gz -C /confluent --strip-components=1 \
    && rm -r confluent.tar.gz \
    && apk del .build-deps

WORKDIR /confluent/bin

VOLUME ["/config"]

CMD [ "./connect-standalone", "/config/connect.properties", "/config/elasticsearch.properties" ]
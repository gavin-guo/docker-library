FROM gaven/alpine:8-jre

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash

ENV MAXWELL_VERSION=1.22.3 \
    MAXWELL_HOME="/maxwell"

RUN set -x \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
        ca-certificates \
        wget \
        tar \
    && wget -q "https://github.com/zendesk/maxwell/releases/download/v${MAXWELL_VERSION}/maxwell-${MAXWELL_VERSION}.tar.gz" \
    && tar -xzf "maxwell-${MAXWELL_VERSION}.tar.gz" \
    && mv "maxwell-${MAXWELL_VERSION}" "$MAXWELL_HOME" \
    && rm -r "maxwell-${MAXWELL_VERSION}.tar.gz" \
    && apk del .build-deps

RUN set -x \
    && mkdir /config

COPY docker-entrypoint.sh /
COPY config.properties /config/

RUN set -x \
    && chmod +x /docker-entrypoint.sh

ENV PATH=$PATH:$MAXWELL_HOME

WORKDIR $MAXWELL_HOME

ENTRYPOINT ["/docker-entrypoint.sh"]
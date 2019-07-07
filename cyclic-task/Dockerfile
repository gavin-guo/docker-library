FROM alpine:3.6

MAINTAINER gavin-guo

RUN apk add --no-cache \
    bash \
    su-exec \
    supervisor

RUN set -x \
    && mkdir -p "/opt/bin"

WORKDIR /opt/

ADD ./launcher.sh /opt/
ADD ./supervisord.conf /opt/

RUN set -x \
    && chmod +x launcher.sh

VOLUME ["/opt/bin"]


ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/opt/supervisord.conf"]
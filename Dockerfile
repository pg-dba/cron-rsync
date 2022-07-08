FROM alpine:latest

RUN set -ex && \
# install bash
    apk add --no-cache bash && \
    apk add --no-cache rsync && \
# making logging pipe
    mkfifo -m 0666 /var/log/cron.log && \
    ln -s /var/log/cron.log /var/log/crond.log

COPY start-cron /usr/sbin

COPY *.sh /etc/cron.d/
RUN chmod 755 /etc/cron.d/*.sh

RUN mkdir -p /cronwork
RUN chmod 777 /cronwork
VOLUME /cronwork

WORKDIR /etc/cron.d

ENTRYPOINT ["/etc/cron.d/docker-entrypoint.sh"]

CMD ["start-cron"]

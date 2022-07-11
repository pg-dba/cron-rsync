FROM alpine:latest

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN set -ex && \
# install bash
    apk add --no-cache bash && \
    apk add --no-cache tzdata && \
    apk add --no-cache linux-pam && \
    apk add --no-cache openssh-client && \
    apk add --no-cache bind-tools && \
    apk add --no-cache sshpass && \
    apk add --no-cache rsync && \
# apk add --no-cache moreutils # 36 mb
# making logging pipe
    mkfifo -m 0666 /var/log/cron.log && \
    ln -s /var/log/cron.log /var/log/crond.log && \
# buns
    echo "export PS1='[\u@\h]\$ '" >> ~/.bashrc && \
    echo 'alias nocomments="sed -e :a -re '"'"'s/<!--.*?-->//g;/<!--/N;//ba'"'"' | grep -v -P '"'"'^\s*(#|;|$)'"'"'"' >> ~/.bashrc

COPY start-cron /usr/sbin
RUN chmod 744 /usr/sbin/start-cron

COPY *.sh /etc/cron.d/
RUN chmod 755 /etc/cron.d/*.sh

RUN mkdir -p /cronwork
RUN chmod 777 /cronwork
VOLUME /cronwork

WORKDIR /etc/cron.d

ENTRYPOINT ["/etc/cron.d/docker-entrypoint.sh"]

CMD ["start-cron"]

# cron-rsync

Запуск cron внутри Docker-контейнера<BR>
https://habr.com/ru/company/redmadrobot/blog/305364/<BR>
https://hub.docker.com/r/renskiy/cron/<BR>
https://github.com/renskiy/cron-docker-image<BR>

В контейнер необходимо передавать все строки crontab как ARG<BR>


Установлен rsync 3.2.4<BR>
https://download.samba.org/pub/rsync/NEWS<BR>
- Reduced memory usage for an incremental transfer that has a bunch of small directories.

ssh-copy-id выполняется скриптом при старте контейнера


Также написаны скрипты rsync-push.sh и rsync-pull.sh для синхронизации по шагам<BR>
- вначале дерево каталогов<BR>
- затем в цикле файлы в каждом каталоге<BR>

Контейнер должен запускаться либо на хосте куда бэкапят данные (rsync pull). Либо на хосте откуда данные бэкапят (rsync push).<BR>
Доступ на хост-партнёр rsync обеспечивается ssh-copy-id.


<HR>

Пример для "посмотреть":<BR>
<pre><code>
docker run --rm -it -h cron-rsync \
  -e TZ='Europe/Moscow' -e CRONHOST=172.27.172.32 -e SSHPASSWORD=Rr123456 \
  -v /tmp:/cronwork \
  sqldbapg/cron-rsync \
  start-cron "\\*/1 \\* \\* \\* \\* env \\| sort 2>&1 1>>/var/log/cron.log" &

docker logs --follow $(docker ps | grep ' sqldbapg/cron-rsync' | awk '{ print $1 }')

docker exec -it $(docker ps | grep ' sqldbapg/cron-rsync' | awk '{ print $1 }') bash -c "crontab -l"

docker exec -it $(docker ps | grep ' sqldbapg/cron-rsync' | awk '{ print $1 }') bash

docker stop $(docker ps | grep ' sqldbapg/cron-rsync' | awk '{ print $1 }')
</code></pre>

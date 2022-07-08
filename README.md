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

<HR>

Пример для "посмотреть":<BR>

docker run --rm -it -h cron-rsync \\<BR>
  -e TZ='Europe/Moscow' -e CRONHOST=172.27.172.32 -e SSHPASSWORD=P@ssw0rd \\<BR>
  -v /tmp:/cronwork \\<BR>
  reg.spsr.tech/devops/cron-rsync:1 \\<BR>
  /bin/bash

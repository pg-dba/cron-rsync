#!/usr/bin/env bash

# Rancher DNS
if [[ "$(cat /etc/resolv.conf | grep '169.254.169.250' | wc -l)" == "0" ]]; then
echo "nameserver 169.254.169.250" > /etc/resolv.conf
fi

# cron timezone
if [ ! -z "${TZ}" ]; then
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo ${TZ} > /etc/timezone
fi

# ssh-copy-id
if [ ! -f /root/.ssh/id_rsa ]&&[ ! -z "${CRONHOST}" ]&&[ ! -z "${SSHPASSWORD}" ]; then
/usr/bin/ssh-keygen -t rsa -b 4096 -q -N "" -f /root/.ssh/id_rsa &>/dev/null
/usr/bin/ssh -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no ${CRONHOST} /bin/true &>/dev/null
SSHPASS=${SSHPASSWORD} /usr/bin/sshpass -e ssh-copy-id ${CRONHOST} &>/dev/null
rm -f ~/.ssh/known_hosts.old &>/dev/null
# оставляем только последний ssh id. остальные удаляем, чтобы не мусорить
SSHKEY=$(cat ~/.ssh/id_rsa.pub | rev | sed 's/ .*//' | rev)
ssh ${CRONHOST} "if test -f $HOME/.ssh/authorized_keys; then if grep -v '${SSHKEY}' $HOME/.ssh/authorized_keys > $HOME/.ssh/tmp; then grep '${SSHKEY}' $HOME/.ssh/authorized_keys | tail -n 1 >> $HOME/.ssh/tmp; cat $HOME/.ssh/tmp > $HOME/.ssh/authorized_keys && rm -f $HOME/.ssh/tmp; else rm -f $HOME/.ssh/tmp; fi; fi;"
fi

set -e

# переносим значения переменных из текущего окружения
env | while read -r LINE; do  # читаем результат команды 'env' построчно
    # делим строку на две части, используя в качестве разделителя "=" (см. IFS)
    IFS="=" read VAR VAL <<< ${LINE}
    # удаляем все предыдущие упоминания о переменной, игнорируя код возврата
    sed --in-place "/^${VAR}/d" /etc/security/pam_env.conf || true
    # добавляем определение новой переменной в конец файла
    echo "${VAR} DEFAULT=\"${VAL}\"" >> /etc/security/pam_env.conf
done

exec "$@"

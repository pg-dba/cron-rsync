#!/bin/bash
# rsync-pull.sh

if [[ ("$#" -eq 3) ]]; then

DATASRV=$1	# Сервер, данные с которого бэкапируются
RSDIR=$2	# Каталог, который бэкапируется
BACKUPDIR=$3	# Каталог, куда бэкапируется (на локальном сервере)

YELLOW='\033[1;33m'
BLUE='\033[1;36m'
GREEN='\033[1;32m'
MAGENTA='\033[1;35m'
NC='\033[0m'
LNPREFIX='[rsync pull] '

# test whether SSH has passwordless access without prompting for password
ssh -o PreferredAuthentications=publickey ${DATASRV} /bin/true
SSHRC=$?

STARTTIME=$(date +%s)
if [[ (${SSHRC} -eq 0) ]]; then

# RSDIRS=$(ssh ${DATASRV} "cd ${RSDIR} && tree -dif --noreport | cut -d '/' -f2-" <<-EOF) # для интерактивного выполнения кода
RSDIRS=$(ssh ${DATASRV} "cd ${RSDIR} && tree -dif --noreport | cut -d '/' -f2-")
if [ -t 0 ]; then # if the script is not run by cron
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${BLUE}rsync pull from ${DATASRV}:${RSDIR} to ${BACKUPDIR} started${NC}"
else
  echo "rsync pull from ${DATASRV}:${RSDIR} to ${BACKUPDIR} started" | ts "${LNPREFIX}"
fi
rsync -aq --delete -f"+ */" -f"- *" ${DATASRV}:${RSDIR}/* ${BACKUPDIR} 2>/dev/null | ts "${LNPREFIX}"
RRC=$?
if [ -t 0 ]; then # if the script is not run by cron
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${BLUE}directory tree synked (RC=${RRC})${NC}"
else
  echo "directory tree synked (RC=${RRC})" | ts "${LNPREFIX}"
fi
for DIRPATH in ${RSDIRS}; do
  if [ -t 0 ]; then # if the script is not run by cron
    echo -en "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${YELLOW}files in directory ${DIRPATH} synking ... ${NC}"
  else
    echo -n "files in directory ${DIRPATH} synking ... " | ts "${LNPREFIX}"
  fi
  rsync -aq --no-recursive ${DATASRV}:${RSDIR}/${DIRPATH}/* ${BACKUPDIR}/${DIRPATH} 2>/dev/null | ts "${LNPREFIX}"
  RRC=$?
  if [ -t 0 ]; then # if the script is not run by cron
    if [[ "${RRC}" = "0" ]]; then
      echo -e "${GREEN}(RC=${RRC})${NC}"
    else
      echo -e "${MAGENTA}(RC=${RRC})${NC}"
    fi
  else
    echo "(RC=${RRC})"
  fi
done
ENDTIME=$(date +%s)
ELAPSED="$(($ENDTIME - $STARTTIME))"
if [ -t 0 ]; then # if the script is not run by cron
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${BLUE}files synked. elapsed time: %s\n\n" "$(date -d@${ELAPSED} -u +%H\ hours\ %M\ min\ %S\ sec)${NC}"
else
  echo "files synked. elapsed time: %s\n\n" "$(date -d@${ELAPSED} -u +%H\ hours\ %M\ min\ %S\ sec)" | ts "${LNPREFIX}"
fi
RC=0

else
RC=-2
echo "ssh connect to ${DATASRV} must be passwordless."
fi

else
RC=-1
echo "Usage:\n rsync-pull.sh u20d1h2 '/data/postgres' '/tmp/PG_BACKUP'"
fi

exit ${RC}

# rm -rf /tmp/PG_BACKUP && mkdir -p /tmp/PG_BACKUP
# du -sh /tmp/PG_BACKUP
# tree -dif --noreport /tmp/PG_BACKUP
# число файлов в каждом каталоге
# find /data/postgres -type d -print0 | xargs -0 -I {} bash -c 'echo -e "$(find {} -maxdepth 1 -type f | wc -l)\t{}"' | sort -k 2
# find /tmp/PG_BACKUP -type d -print0 | xargs -0 -I {} bash -c 'echo -e "$(find {} -maxdepth 1 -type f | wc -l)\t{}"' | sort -k 2

#!/bin/bash
# rsync-push.sh

if [[ ("$#" -eq 3) ]]; then

RSDIR=$1	# Каталог, который бэкапируется
BACKUPSRV=$2	# Сервер бэкапирования
BACKUPDIR=$3	# Каталог, куда бэкапируется

YELLOW='\033[1;33m'
BLUE='\033[1;36m'
GREEN='\033[1;32m'
MAGENTA='\033[1;35m'
NC='\033[0m'

# test whether SSH has passwordless access without prompting for password
ssh -o PreferredAuthentications=publickey ${BACKUPSRV} /bin/true
SSHRC=$?

if [[ (${SSHRC} -eq 0) ]]; then

cd ${RSDIR} && (
RSDIRS=$(tree -dif --noreport | cut -d '/' -f2-)
if [ -t 0 ]; then # if the script is not run by cron
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${BLUE}rsync push from ${RSDIR} to ${BACKUPSRV}:${BACKUPDIR} started${NC}"
else
  echo "rsync push from ${RSDIR} to ${BACKUPSRV}:${BACKUPDIR} started"
fi
rsync -aq --delete -f"+ */" -f"- *" . ${BACKUPSRV}:${BACKUPDIR}
RRC=$?
if [ -t 0 ]; then # if the script is not run by cron
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${BLUE}directory tree synked (RC=${RRC})${NC}"
else
  echo "directory tree synked (RC=${RRC})"
fi
for DIRPATH in ${RSDIRS}; do
  if [ -t 0 ]; then # if the script is not run by cron
    echo -en "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${YELLOW}files in directory ${DIRPATH} synking ... ${NC}"
  else
    echo -n "files in directory ${DIRPATH} synking ... "
  fi
  rsync -aq --delete --no-recursive ${DIRPATH}/* ${BACKUPSRV}:${BACKUPDIR}/${DIRPATH} 2>/dev/null
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
done ) &&
cd - 1>/dev/null
if [ -t 0 ]; then # if the script is not run by cron
  echo -e "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ${BLUE}files synked${NC}"
else
  echo "files synked"
fi
RC=0

else
RC=-2
echo "ssh connect to ${BACKUPSRV} must be passwordless."
fi

else
RC=-1
echo "Usage:\n rsync-push.sh '/cronwork' u16d1h5 '/tmp/PG_BACKUP'"
fi

exit ${RC}

# rm -rf /tmp/PG_BACKUP && mkdir -p /tmp/PG_BACKUP
# du -sh /tmp/PG_BACKUP
# tree -dif --noreport /tmp/PG_BACKUP
# число файлов в каждом каталоге
# find /data/postgres -type d -print0 | xargs -0 -I {} bash -c 'echo -e "$(find {} -maxdepth 1 -type f | wc -l)\t{}"' | sort -k 2
# find /tmp/PG_BACKUP -type d -print0 | xargs -0 -I {} bash -c 'echo -e "$(find {} -maxdepth 1 -type f | wc -l)\t{}"' | sort -k 2

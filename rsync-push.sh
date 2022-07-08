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
echo -e "[$(date --iso-8601=seconds)] ${BLUE}rsync push from ${RSDIR} to ${BACKUPSRV}:${BACKUPDIR} started${NC}"
rsync -aq --delete -f"+ */" -f"- *" . ${BACKUPSRV}:${BACKUPDIR}
RRC=$?
echo -e "[$(date --iso-8601=seconds)] ${BLUE}directory tree synked (RC=${RRC})${NC}"
for DIRPATH in ${RSDIRS}; do
  echo -en "[$(date --iso-8601=seconds)] ${YELLOW}files in directory ${DIRPATH} synking ... ${NC}"
  rsync -aq --no-recursive ${DIRPATH}/* ${BACKUPSRV}:${BACKUPDIR}/${DIRPATH} 2>/dev/null
  RRC=$?
  if [[ "${RRC}" = "0" ]]; then
  echo -e "${GREEN}(RC=${RRC})${NC}"
  else
  echo -e "${MAGENTA}(RC=${RRC})${NC}"
  fi
done ) &&
cd - 1>/dev/null
echo -e "[$(date --iso-8601=seconds)] ${BLUE}files synked${NC}"
RC=0

else
RC=-2
echo -e "ssh connect to ${BACKUPSRV} must be passwordless."
fi

else
RC=-1
echo -e "Usage:\n rsync-push.sh '/data/postgres' u16d1h5 '/tmp/PG_BACKUP'"
fi

exit ${RC}

# rm -rf /tmp/PG_BACKUP && mkdir -p /tmp/PG_BACKUP
# du -sh /tmp/PG_BACKUP
# tree -dif --noreport /tmp/PG_BACKUP
# число файлов в каждом каталоге
# find /data/postgres -type d -print0 | xargs -0 -I {} bash -c 'echo -e "$(find {} -maxdepth 1 -type f | wc -l)\t{}"' | sort -k 2
# find /tmp/PG_BACKUP -type d -print0 | xargs -0 -I {} bash -c 'echo -e "$(find {} -maxdepth 1 -type f | wc -l)\t{}"' | sort -k 2

#!/bin/bash
# rsync-cmd.sh
# https://manpage.me/?rsync
LNPREFIX='[rsync] '

if [[ ("$#" -eq 2) ]]; then
STARTTIME=$(date +%s)
  rsync -aAXvv --delete --numeric-ids --exclude='lost+found' $1/* $2 2>&1 | (head -1 ; tail -4) | grep -v -E '^s*$' | ts "${LNPREFIX}"
  RC=$?
ENDTIME=$(date +%s)
ELAPSED="$(($ENDTIME - $STARTTIME))"
  echo "(RC=${RC}) elapsed time: %s\n\n" "$(date -d@${ELAPSED} -u +%H\ hours\ %M\ min\ %S\ sec)" | ts "${LNPREFIX}"
else
  echo -e 'Usage:\n rsync-cmd.sh ${CRONHOST}:/data/postgres2/10/data /cronwork \n rsync-cmd.sh /cronwork ${CRONHOST}:/tmp/PG_BACKUP '
  RC=-1
fi
exit ${RC}

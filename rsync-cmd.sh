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
  echo "(RC=${RC}) elapsed time: $((${ELAPSED}/3600)) hours $(((${ELAPSED}/60)%60)) minutes $((${ELAPSED}%60)) seconds" | ts "${LNPREFIX}"
else
  echo -e 'Usage:\n rsync-cmd.sh ${CRONHOST}:/data/postgres2/10/data /cronwork \n rsync-cmd.sh /cronwork ${CRONHOST}:/tmp/PG_BACKUP '
  RC=-1
fi
exit ${RC}

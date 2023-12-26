#!/bin/bash
# rsync-cmd.sh
LNPREFIX='[rsync] '

if [[ ("$#" -eq 2) ]]; then
  rsync -avv --delete $1/* $2 2>&1 | tail -n 4 | grep -v -E '^s*$' | ts "${LNPREFIX}"
  RC=$?
  echo "(RC=${RC})" | ts "${LNPREFIX}"
else
  echo -e 'Usage:\n rsync-cmd.sh ${CRONHOST}:/data/postgres2/10/data /cronwork \n rsync-cmd.sh /cronwork ${CRONHOST}:/tmp/PG_BACKUP '
  RC=-1
fi
exit ${RC}

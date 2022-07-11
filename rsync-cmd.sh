#!/bin/bash
# rsync-cmd.sh

if [[ ("$#" -eq 2) ]]; then
  rsync -avv --delete "$1" "$2" 2>&1 | tac | sed '1,4p;d' | grep -v '^s*(#|;|$)' | tac
  RC=$?
else
  echo -e 'Usage:\n rsync-cmd.sh "${CRONHOST}:/data/postgres2/10/data/*" "/cronwork" \n rsync-cmd.sh "/cronwork/*" "${CRONHOST}:/tmp/PG_BACKUP" '
  RC=-1
fi

exit ${RC}

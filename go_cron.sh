#! /bin/sh

set -e

if [ "${SCHEDULE}" != "**None**" ]; then
  exec go-cron -s "$SCHEDULE" -- /bin/bash -c "/etc/service/gocron/backup.sh"
fi

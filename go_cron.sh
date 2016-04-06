#! /bin/sh

set -e

if [ "${SCHEDULE}" != "**None**" ]; then
  exec go-cron "$SCHEDULE" /bin/sh /etc/service/gocron/backup.sh
fi

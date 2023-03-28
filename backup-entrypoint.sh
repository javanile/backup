#!/usr/bin/env bash
set -e

crontab=/var/spool/cron/crontabs/root

>$crontab

if [[ "$1" =~ ^[0-9*] ]]; then
  while test $# -gt 0; do
    echo "$1" >> $crontab
    shift
  done
  set -- crond -f -L /dev/stdout -l 8
fi

if [ -f /etc/crontab ]; then
  cat /etc/crontab >> $crontab
fi

start_date=$(date +'%Y-%m-%d %H:%M:%S')
echo "==> File: $crontab"
cat $crontab
echo

echo "==> Start scheduled job at: ${start_date}"
docker-entrypoint.sh "$@"
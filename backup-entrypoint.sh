#!/usr/bin/env bash
set -e

crontab=/var/spool/cron/crontabs/root

>$crontab
chmod 600 $crontab
chown root:crontab $crontab

if [[ "$1" =~ ^[0-9*] ]]; then
  while test $# -gt 0; do
    echo "$1 > /dev/stdout 2>&1" >> $crontab
    shift
  done
  set -- cron -f -L 15
fi

if [ -f /etc/crontab ]; then
  #cat /etc/crontab >> $crontab
  #>/etc/crontab
  #chmod 600 /etc/crontab
  echo "-----"
  cat /etc/crontab
fi

rsyslogd && true

crontab -u root $crontab
crontab -l

start_date=$(date +'%Y-%m-%d %H:%M:%S')
echo "==> File: $crontab"
cat $crontab
echo

echo "==> Start scheduled job at: ${start_date}"
exec "$@"
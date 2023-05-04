#!/usr/bin/env bash
set -e

crontab=/var/spool/cron/crontabs/root

## store environment variables
printenv \
  | sed 's/^\(.*\)$/export \1/g' \
  | grep -E '^export FTP_|^export DB_|^export REMOTE_|^export LOCAL_|^export COMPRESS' > /run/crond.env

cat /run/crond.env

>$crontab
chmod 600 $crontab
chown root:crontab $crontab

if [[ "$1" =~ ^[0-9*] ]]; then
  while test $# -gt 0; do
    echo "$1 > /var/log/cron 2>&1" >> $crontab
    shift
  done
  set -- cron-foreground.sh
fi

if [ -f /etc/crontab ]; then
  #cat /etc/crontab >> $crontab
  #>/etc/crontab
  #chmod 600 /etc/crontab
  echo "-----"
  #cat /etc/crontab
fi

#crontab -u root $crontab
#crontab -l

start_date=$(date +'%Y-%m-%d %H:%M:%S')
echo "==> File: $crontab"
cat $crontab
echo

echo "==> Start scheduled job at: ${start_date}"
exec "$@"

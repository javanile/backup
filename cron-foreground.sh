#!/bin/bash
set -e

rsyslogd && true
cron -L 15

tail -f /var/log/cron

#!/bin/bash
set -e

rsyslogd && true
cron -f -L 15

#tail -f /var/log/cron

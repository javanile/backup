#!/bin/bash
set -e

rsyslogd
cron -f -L 15


#!/usr/bin/env bash
set -e

BACKUP_DATE=$(date -d "${BACKUP_DATE}" '+%y-%m-%d %H:%M:%S')

FILE_DATE=$(date -d "${BACKUP_DATE}" '+%Y%m%d_%H%M')

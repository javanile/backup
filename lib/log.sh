#!/usr/bin/env bash
# Author: Ambroise Maupate

source /run/crond.env

PGDUMP="$(which pg_dump)"
MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
SPLIT="$(which split)"
LFTP="$(which lftp)"
GZIP="$(which gzip)"
MKDIR="$(which mkdir)"
TAR_OPTIONS="-zcf"
SPLIT_OPTIONS="-b${CHUNK_SIZE}m"
## --column-statistics=0
SQL_OPTIONS="--defaults-extra-file=/etc/mysql/temp_db.cnf --no-tablespaces"
TMP_FOLDER=/tmp
TAR_FILE="${FILE_DATE}_files.tar.gz"
SQL_FILE="${FILE_DATE}_database.sql.gz"
LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

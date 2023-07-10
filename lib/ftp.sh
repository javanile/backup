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

##
#
##
function ftp_file_upload() {
  local file=$1
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${file};
bye;
EOF
}

##
#
##
function ftp_file_list() {
  ${LFTP} ${LFTP_CMD} << EOF
cd ${REMOTE_PATH}
cache flush
cls -q -1  > $1
quit
EOF
}

##
#
##
function ftp_clean() {
  local list=$(mktemp)
  local clean=$(mktemp)
  local file_mask="${1:8:1}${1:13}"

  ftp_file_list "${list}"

  while read -r file; do
    [ -z "$file" ] && continue
    [ "$file" = "$1" ] && continue
    [ "${file:8:1}${file:13}" != "$file_mask" ] && continue
    [ "${file:0:4}" != "${1:0:4}" ] && continue
    echo "rm -fr ${file}" >> "${clean}"
  done < "${list}"

  ${LFTP} ${LFTP_CMD} << EOF
cd ${REMOTE_PATH}
$(sed '1d' "${clean}")
cache flush
quit
EOF
}

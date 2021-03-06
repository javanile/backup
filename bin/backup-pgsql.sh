#!/usr/bin/env bash
# Author: Ambroise Maupate

source /run/crond.env
source /usr/local/lib/backup/env.sh

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

#
# Optional Postgres dump
#
if [[ -z "${PGDATABASE}" ]]; then
  #echo "[`date '+%Y-%m-%d %H:%M:%S'`] No PostgreSQL database to backup."
  true
else
  # PostgreSQL dump
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] PostgreSQL dump backup…"

  cat > ~/.pgpass <<- EOF
${PGHOST}:${PGPORT}:${PGDATABASE}:${PGUSER}:${PGPASSWORD}
EOF

  $PGDUMP --no-password $PGDATABASE | gzip > ${TMP_FOLDER}/${SQL_FILE}
  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending PostgreSQL dump over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${SQL_FILE};
ls;
bye;
EOF
fi

#!/usr/bin/env bash
# Author: Ambroise Maupate

source /run/crond.env
source /usr/local/lib/backup/env.sh
source /usr/local/lib/backup/log.sh
source /usr/local/lib/backup/ftp.sh

PGDUMP="$(which pg_dump)"
MYSQLDUMP="$(which mysqldump)"
MYSQL="$(which mysql)"
TAR="$(which tar)"
SPLIT="$(which split)"
LFTP="$(which lftp)"
GZIP="$(which gzip)"
MKDIR="$(which mkdir)"
TAR_OPTIONS="-zcf"
SPLIT_OPTIONS="-b${CHUNK_SIZE}m"
## --column-statistics=0
MYSQL_OPTIONS="--defaults-extra-file=/etc/mysql/temp_db.cnf"
MYSQLDUMP_OPTIONS="--defaults-extra-file=/etc/mysql/temp_db.cnf --no-tablespaces"
TMP_FOLDER=/tmp
TAR_FILE="${FILE_DATE}_files.tar.gz"
LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

## Create credential client file
cat > /etc/mysql/temp_db.cnf <<- EOF
[client]
user = "${DB_USER}"
password = "${DB_PASS}"
host = "${DB_HOST}"
EOF

##
# Backup single database
##
backup_mysql_database() {
  SQL_FILE="${FILE_DATE}_mysql_${DB_NAME}.sql.gz"

  log "MySQL dump '$DB_NAME' backup"

  $MYSQLDUMP $MYSQLDUMP_OPTIONS -u $DB_USER -h $DB_HOST $DB_NAME | gzip > ${TMP_FOLDER}/${SQL_FILE}

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sending MySQL dump '${SQL_FILE}' over FTP"

  ftp_file_upload "${TMP_FOLDER}/${SQL_FILE}"

  log "File '${SQL_FILE}' successful stored."
}

##
# Backup single database
##
clean_mysql_database() {
  SQL_FILE="${FILE_DATE}_mysql_${DB_NAME}.sql.gz"

  ftp_clean "${SQL_FILE}"
}

#
# MySQL dump
#
if [ -z "${DB_NAME}" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] No database to backup."
else
  if [ "${DB_NAME}" = "*" ]; then
    ignore_database='information_schema|mysql|performance_schema|sys'
    for DB_NAME in $($MYSQL $MYSQL_OPTIONS -u $DB_USER -h $DB_HOST -B -N -e "SHOW DATABASES;" | grep -v -E '^('$ignore_database')$'); do
      backup_mysql_database
      clean_mysql_database
    done
  else
    backup_mysql_database
    clean_mysql_database
  fi
fi

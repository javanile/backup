#!/usr/bin/env bash
# Author: Ambroise Maupate

source /run/crond.env
source backup-env.sh

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

if [[ $COMPRESS -eq 0 ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Do not compress files backup"
  TAR_OPTIONS="-cf"
  TAR_FILE="${FILE_DATE}_files.tar"
fi

if [[ ! -d ${LOCAL_PATH} ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists."
  exit 1
fi

# Control will enter here if /data exists.
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Archiving ${LOCAL_PATH} folder…"
$TAR $TAR_OPTIONS ${TMP_FOLDER}/${TAR_FILE} ${LOCAL_PATH}

# IF CHUNK_SIZE is greater than 0 we split tar archive in chunks for better stability using FTP transfers
# This allow transfer to resume if connection is lost using mirror command.
if [[ $CHUNK_SIZE -gt 0 ]]; then
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Splitting ${TMP_FOLDER}/${TAR_FILE} into ${CHUNK_SIZE}MB parts.";
  $MKDIR ${TMP_FOLDER}/${FILE_DATE}_files;
  $SPLIT $SPLIT_OPTIONS ${TMP_FOLDER}/${TAR_FILE} ${TMP_FOLDER}/${FILE_DATE}_files/${TAR_FILE}.part;
  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${TMP_FOLDER}/${FILE_DATE}_files folder over FTP using ${PARALLEL_UPLOADS} parallel uploads…";
  # Use mirror for parallel upload (2), recursive upload and auto-resume
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
mirror -R -P ${PARALLEL_UPLOADS} ${TMP_FOLDER}/${FILE_DATE}_files ${FILE_DATE}_files;
bye;
EOF
else
  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${TMP_FOLDER}/${TAR_FILE} file over FTP";
  ${LFTP} ${LFTP_CMD} <<EOF
cache flush;
cd ${REMOTE_PATH};
put ${TMP_FOLDER}/${TAR_FILE};
bye;
EOF
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] Files upload was done."

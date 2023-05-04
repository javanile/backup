#!/bin/bash

LFTP="$(which lftp)"
LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

${LFTP} -e "debug;pwd;ls;bye;" ${LFTP_CMD};

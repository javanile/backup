FROM debian:11-slim
MAINTAINER Ambroise Maupate <ambroise@rezo-zero.com>
LABEL description="Backup a data-oriented container and a \
MariaDB/MySQL container and upload them to a FTP server using lftp." \
vendor="Ambroise Maupate"

ENV DEBIAN_FRONTEND noninteractive
ENV FTP_USER user
ENV FTP_PASS pass
ENV FTP_HOST mybackupserver.test
ENV FTP_PORT 21
ENV FTP_PROTO ftp
ENV LOCAL_PATH /data
ENV REMOTE_PATH /my/backup/dir
ENV COMPRESS 1
# PostgreSQL defaults
ENV PGHOST db
ENV PGPORT 5432
ENV PGUSER postgres
# Split bytes in MB
ENV CHUNK_SIZE 0
# LFTP mirror max parallel uploads
# reduce this if your server cannot handle too much connections.
ENV PARALLEL_UPLOADS 3

RUN apt-get update -yqq && \
    apt-get install -y ca-certificates openssh-client default-mysql-client postgresql-client lftp && \
    mkdir -p /backups

RUN apt-get update -yqq && \
    apt-get install -y ca-certificates cron rsyslog

ADD etc/lftp.conf /etc/lftp.conf
ADD etc/ssh/ssh_config.d/strict.conf /etc/ssh/ssh_config.d/strict.conf
COPY backup.sh backup-entrypoint.sh cron-foreground.sh /usr/local/bin/

# Create cronjob log file
RUN touch /var/log/cron
RUN ln -sf /proc/$$/fd/1 /var/log/cron
RUN echo "cron.* /dev/stdout" >> /etc/rsyslog.conf && rm -fr /etc/cron.* && mkdir /etc/cron.d

#CMD ["/bin/bash","/conf/doBackup.sh"]

ENTRYPOINT ["backup-entrypoint.sh"]
CMD ["cron-foreground.sh"]

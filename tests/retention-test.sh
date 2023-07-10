#!/usr/bin/env bash


docker compose run -e BACKUP_DATE=2019-12-30 --rm backup backup
docker compose run -e BACKUP_DATE=2020-01-01 --rm backup backup
docker compose run -e BACKUP_DATE=2020-01-02 --rm backup backup
docker compose run -e BACKUP_DATE=2020-01-03 --rm backup backup

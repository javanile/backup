#!/usr/bin/env bash


docker compose run -e BACKUP_DATE=2020-01-01 --rm backup backup

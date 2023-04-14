
build:
	@chmod +x backup.sh backup-entrypoint.sh cron-foreground.sh
	@docker-compose build backup

release:
	@git add .
	@git commit -am "New release!"
	@git push
	@docker login -u javanile
	@docker build -t "javanile/crontab:latest" .
	@docker push "javanile/crontab:latest"

## ====
## Test
## ====

test-crontab-file:
	@docker compose run --rm crontab cat /etc/crontab

test-docker-ps:
	@docker compose run --rm crontab docker ps

test-up: build
	@rm -f debug.log date.log
	@echo "* * * * * root date >> /app/debug.log" > crontab
	@docker compose up backup

test-bash: build
	@docker compose run --rm backup bash

test-log: build
	@>crontab
	@docker compose up -d --force-recreate backup
	@docker compose logs -f backup

test-backup: build
	@>crontab && rm -fr tmp/ftp/backup
	@docker compose up -d --force-recreate
	@docker compose exec backup backup.sh

build:
	docker build -f Dockerfile  -t odoo:13.0 .
compose:
	docker-compose up -d
stop:
	docker-compose stop
start:
	docker-compose start
clear:
	docker-compose rm -f
prune:
	docker system prune -af

build:
	docker build -t odoo:13.0 .
compose:
	docker-compose up -d
stop:
	docker-compose stop
start:
	docker-compose start
clear:
	make stop
	docker-compose rm -f
prune:
	docker system prune -af
logs:
	docker-compose logs -f --tail 20
scaffold:
	sudo docker exec -it -u 0 odoo-develop odoo scaffold $(name) /opt/odoo/extra-addons

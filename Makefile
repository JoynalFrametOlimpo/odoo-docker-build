build:
	docker build -t odoo:19.0 .
compose:
	docker compose up -d
stop:
	docker compose stop
start:
	docker compose start
clear:
	make stop
	docker compose rm -f && docker volume rm odoo-docker-build_database odoo-docker-build_filestore
prune:
	docker system prune -af
logs:
	docker compose logs -f --tail 20
scaffold:
	docker exec -it -u 0 odoo-develop odoo scaffold $(name) /opt/odoo/extra-addons
odoo-restart:
	docker restart odoo-develop/ && docker logs -f odoo-develop/ --tail $(line)
uninstall:
	apt remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && rm -rf ./backup-environment && delgroup docker 

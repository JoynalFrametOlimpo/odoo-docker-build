build:
  docker build -t odoo-ocb:13.0 -f .

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

#!/bin/bash

set -e

###############################
echo PACKAGE
echo DOCKER COMPOSE
sed -i 's/.\/djangorest\/src\/media/\/docker\/balhom\/volumes\/balhom-backend\/media/g' backend/docker-compose.yml
sed -i 's/.\/djangorest\/src\/static/\/docker\/balhom\/volumes\/balhom-backend\/static/g' backend/docker-compose.yml
sed -i 's/.\/logs\/backend/\/docker\/balhom\/volumes\/balhom-backend\/app_logs/g' backend/docker-compose.yml
sed -i 's/.\/logs\/celery_worker/\/docker\/balhom\/volumes\/balhom-backend\/celery_worker_logs/g' backend/docker-compose.yml
sed -i 's/.\/logs\/celery_beat/\/docker\/balhom\/volumes\/balhom-backend\/celery_beat_logs/g' backend/docker-compose.yml
sed -i 's/.\/logs\/nginx/\/docker\/balhom\/volumes\/balhom-backend\/nginx_logs/g' backend/docker-compose.yml
sed -i 's/.\/certs/\/docker\/balhom\/volumes\/balhom-backend\/certs/g' backend/docker-compose.yml
sed -i 's/external: false/external: true/g' backend/docker-compose.yml
rm -rf backend/certbot
rm -rf backend/redis
rm -rf backend/scripts
rm -rf backend/src/media
mv backend balhom-backend
tar -czf balhom-backend.tar.gz balhom-backend
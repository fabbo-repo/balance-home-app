#!/bin/bash

rm -r balance_app
mkdir balance_app

cp ./extras_db.env ./balance_app/
cp ./extras_app.env ./balance_app/
cp ./extras_nginx.env ./balance_app/
cp ./app_entrypoint.sh ./balance_app/
cp ./celery_entrypoint.sh ./balance_app/
cp -r ./database ./balance_app/
cp -r ./nginx ./balance_app/

cp ./docker-compose_letsencrypt.yml ./balance_app/
cp ./docker-compose.yml ./balance_app/
cp ./Dockerfile ./balance_app/
cp -r ../../../djangorest/* ./balance_app/
#!/bin/bash

set -e

###############################
docker-compose run --entrypoint "sh" api -c "python manage.py migrate"
docker-compose run --entrypoint "sh" api -c "python manage.py createbuckets"
docker-compose run --entrypoint "sh" api -c "python manage.py collectstatic --no-input"
docker-compose run --entrypoint "sh" api -c "python manage.py collectmedia"
docker-compose run --entrypoint "sh" api -c "python manage.py createsuperuser"
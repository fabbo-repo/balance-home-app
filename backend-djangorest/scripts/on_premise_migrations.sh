#!/bin/bash

set -e

###############################
echo MIGRATIONS
cd backend/
docker-compose build
if docker-compose run --no-deps --rm --entrypoint="" backend python manage.py migrate --check; then
    echo Migrations applied
else
    echo Applying migrations
    docker-compose run --no-deps --rm --entrypoint="" backend python manage.py migrate --noinput
fi
cd -
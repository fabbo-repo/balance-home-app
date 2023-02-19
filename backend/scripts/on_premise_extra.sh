#!/bin/bash

set -e

###############################
echo SUPER USER
cd backend/
if docker-compose run --no-deps --rm --entrypoint="" backend sh -c 'python manage.py createsuperuser --email $APP_SUPERUSER_EMAIL --username $APP_SUPERUSER_USERNAME --no-input'; then
    echo Superuser created
else
    echo Superuser already created, skipping
fi
cd -

###############################
echo APP COMMANDS
cd backend/
echo "# Executing balance schedule setup"
docker-compose run --rm --entrypoint="" backend python manage.py balance_schedule_setup
echo "# Executing create balance models"
docker-compose run --rm --entrypoint="" backend python manage.py create_balance_models
echo "# Executing coin schedule setup"
docker-compose run --rm --entrypoint="" backend python manage.py coin_schedule_setup
echo "# Executing create coin models"
docker-compose run --rm --entrypoint="" backend python manage.py create_coin_models
echo "# Executing users schedule setup"
docker-compose run --rm --entrypoint="" backend python manage.py users_schedule_setup
echo "# Creting default invitation code"
docker-compose run --rm --entrypoint="" backend python manage.py inv_code_create --init
docker-compose down
cd -

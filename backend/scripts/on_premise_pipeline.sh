#!/bin/bash

set -e

FLAGS=$(getopt -a --options h --long "env-dir:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h )                      exit;;
        --env-dir )               ENV_DIR=$2; shift 2;;
        --) shift; break;;
    esac
done

if [ -z "$ENV_DIR" ]; then
    echo "ENV_DIR required"
    exit -1
fi

###############################
echo GIT CLONE
rm -rf BalanceHomeApp
git clone -b fix-pipelines https://github.com/fabbo-repo/BalanceHomeApp.git

###############################
echo DOCKER COMPOSE
sed -i 's/.\/djangorest\/src\/media/.\/media/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/djangorest\/src\/static/.\/static/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/external: true/external: false/g' ./BalanceHomeApp/backend/docker-compose.yml

###############################
echo ENV DIR
cp "$ENV_DIR/backend_app.env" ./BalanceHomeApp/backend/

###############################
echo TESTING
cd ./BalanceHomeApp/backend/djangorest/src/
python manage.py test
cd -

###############################
echo STATIC
cd ./BalanceHomeApp/backend/
docker-compose run --build --rm --entrypoint="" backend python manage.py collectstatic --noinput
cd -

###############################
echo MIGRATIONS
cd ./BalanceHomeApp/backend/
if docker-compose run --build --rm --entrypoint="" backend python manage.py migrate --check; then
    echo Migrations applied
else
    echo Applying migrations
    docker-compose run --build --rm --entrypoint="" backend python manage.py migrate --noinput
fi
docker-compose down
cd -

###############################
echo SUPER USER
cd ./BalanceHomeApp/backend/
if docker-compose run --build --rm --entrypoint="" backend sh -c 'python manage.py createsuperuser --email $APP_SUPERUSER_EMAIL --username $APP_SUPERUSER_USERNAME --no-input'; then
    echo Superuser created
else
    echo Superuser already created, skipping
fi
cd -

###############################
echo APP COMMANDS
cd ./BalanceHomeApp/backend/
echo "# Executing balance schedule setup"
docker-compose run --build --rm --entrypoint="" backend python manage.py balance_schedule_setup
echo "# Executing create balance models"
docker-compose run --build --rm --entrypoint="" backend python manage.py create_balance_models
echo "# Executing coin schedule setup"
docker-compose run --build --rm --entrypoint="" backend python manage.py coin_schedule_setup
echo "# Executing create coin models"
docker-compose run --build --rm --entrypoint="" backend python manage.py create_coin_models
echo "# Executing users schedule setup"
docker-compose run --build --rm --entrypoint="" backend python manage.py users_schedule_setup
echo "# Creting default invitation code"
docker-compose run --build --rm --entrypoint="" backend python manage.py inv_code_create --init
cd -

###############################
echo PACKAGE
echo DOCKER COMPOSE
sed -i 's/.\/media/\/docker\/balhom\/volumes\/balhom-backend\/media/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/static/\/docker\/balhom\/volumes\/balhom-backend\/static/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/logs\/backend/\/docker\/balhom\/volumes\/balhom-backend\/app_logs/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/logs\/celery/\/docker\/balhom\/volumes\/balhom-backend\/celery_logs/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/logs\/nginx/\/docker\/balhom\/volumes\/balhom-backend\/nginx_logs/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/certs/\/docker\/balhom\/volumes\/balhom-backend\/certs/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/external: false/external: true/g' ./BalanceHomeApp/backend/docker-compose.yml
rm -rf BalanceHomeApp/backend/certbot
rm -rf BalanceHomeApp/backend/redis
rm -rf BalanceHomeApp/backend/scripts
tar -czf balhom-backend.tar.gz BalanceHomeApp/backend
rm -rf BalanceHomeApp
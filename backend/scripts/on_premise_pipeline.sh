#!/bin/bash

set -e

FLAGS=$(getopt -a --options h --long "env-dir:,certs-dir:,old-media-dir:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h )                      exit;;
        --env-dir )               ENV_DIR=$2; shift 2;;
        --certs-dir )             CERTS_DIR=$2; shift 2;;
        --old-media-dir )         MEDIA_DIR=$2; shift 2;;
        --) shift; break;;
    esac
done

if [ -z "$ENV_DIR" ]; then
    echo "ENV_DIR required"
    exit -1
fi
if [ -z "$CERTS_DIR" ]; then
    echo "CERTS_DIR required"
    exit -1
fi

###############################
echo GIT CLONE
rm -rf BalanceHomeApp
git clone https://github.com/fabbo-repo/BalanceHomeApp.git

###############################
echo DOCKER COMPOSE
sed -i 's/.\/djangorest\/src\/media/.\/media/g' ./BalanceHomeApp/backend/docker-compose.yml
sed -i 's/.\/djangorest\/src\/static/.\/static/g' ./BalanceHomeApp/backend/docker-compose.yml

###############################
echo ENV DIR
cp "$ENV_DIR/backend_app.env" ./BalanceHomeApp/backend/

###############################
echo CERTS DIR
mkdir -p ./BalanceHomeApp/backend/certs/
cp "$CERTS_DIR/fullchain.pem" ./BalanceHomeApp/backend/certs/
cp "$CERTS_DIR/privkey.pem" ./BalanceHomeApp/backend/certs/

###############################
echo OLD MEDIA DIR
mkdir -p ./BalanceHomeApp/backend/media
if [ ! -z "$MEDIA_DIR" ]; then
    yes | cp -r $MEDIA_DIR/* ./BalanceHomeApp/backend/media/
else
    cp -r ./BalanceHomeApp/backend/djangorest/src/media/* ./BalanceHomeApp/backend/media/
fi

###############################
echo TESTING
cd ./BalanceHomeApp/backend/djangorest/src/
python manage.py test
cd -

###############################
echo MEDIA
mkdir -p ./BalanceHomeApp/backend/media
yes | cp -r ./BalanceHomeApp/backend/djangorest/src/media/* ./BalanceHomeApp/backend/media/

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
rm -rf BalanceHomeApp/backend/certbot
rm -rf BalanceHomeApp/backend/redis
rm -rf BalanceHomeApp/backend/scripts
tar -czf balhom-backend.tar.gz BalanceHomeApp/backend
rm -rf BalanceHomeApp
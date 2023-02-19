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
echo ENV DIR
cp "$ENV_DIR/backend_app.env" backend/

###############################
echo DOCKER COMPOSE
sed -i 's/external: true/external: false/g' backend/docker-compose.yml

###############################
echo STATIC
cd backend/djangorest/src
pip install -r requirements.txt
python manage.py collectstatic --noinput
cd -
mv backend/djangorest/src/static static

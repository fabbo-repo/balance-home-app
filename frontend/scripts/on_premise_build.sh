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
cp "$ENV_DIR/.env" frontend/flutter/

###############################
echo DOCKER COMPOSE
sed -i 's/.\/flutter\/build\/web/docker\/balhom\/volumes\/balhom-frontend\/web/g' frontend/docker-compose.yml

###############################
echo BUILD
cd frontend/flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
cd -
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
git clone https://github.com/fabbo-repo/BalanceHomeApp.git

###############################
echo DOCKER COMPOSE
sed -i 's/.\/flutter\//docker\/balhom\/volumes\/balhom-frontend\/web/g' ./BalanceHomeApp/frontend/docker-compose.yml

###############################
echo ENV DIR
cp "$ENV_DIR/.env" ./BalanceHomeApp/frontend/flutter/

###############################
echo BUILD
cd ./BalanceHomeApp/frontend/flutter
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web
cd -
mkdir -p ./BalanceHomeApp/frontend/web
cp -r ./BalanceHomeApp/frontend/flutter/build/web/* ./BalanceHomeApp/frontend/web/
rm -rf ./BalanceHomeApp/frontend/flutter
rm -rf ./BalanceHomeApp/frontend/scripts

###############################
echo PACKAGE
tar -czf balhom-frontend.tar.gz BalanceHomeApp/frontend
rm -rf BalanceHomeApp
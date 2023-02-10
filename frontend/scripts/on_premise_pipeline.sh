#!/bin/bash

set -e

FLAGS=$(getopt -a --options h --long "env-dir:,certs-dir:" -- "$@")

eval set -- "$FLAGS"

while true; do
    case "$1" in
        -h )                      exit;;
        --env-dir )               ENV_DIR=$2; shift 2;;
        --certs-dir )             CERTS_DIR=$2; shift 2;;
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
echo ENV DIR
cp "$ENV_DIR/.env" ./BalanceHomeApp/frontend/

###############################
echo CERTS DIR
mkdir -p ./BalanceHomeApp/frontend/certs/
cp "$CERTS_DIR/fullchain.pem" ./BalanceHomeApp/frontend/certs/
cp "$CERTS_DIR/privkey.pem" ./BalanceHomeApp/frontend/certs/

###############################
echo BUILD
cd ./BalanceHomeApp/frontend/flutter
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web
cd -
mkdir -p ./BalanceHomeApp/frontend/web
cp ./BalanceHomeApp/frontend/flutter/build/web/* ./BalanceHomeApp/frontend/web/

###############################
echo PACKAGE
tar -czf balhom-frontend.tar.gz BalanceHomeApp/frontend
rm -rf BalanceHomeApp
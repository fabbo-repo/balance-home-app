#!/bin/bash

set -e

###############################
echo PACKAGE
cd frontend/flutter
flutter build web
cd -
mkdir -p frontend/web
cp -r frontend/flutter/build/web/* frontend/web/
rm -rf frontend/flutter
rm -rf frontend/scripts
mv frontend balhom-frontend
tar -czf balhom-frontend.tar.gz frontend
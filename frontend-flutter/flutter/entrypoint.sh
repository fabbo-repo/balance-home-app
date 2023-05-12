#!/bin/sh

# Exit immediately if any of the following command exits 
# with a non-zero status
set -e

# https://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
cat << "EOF"


$$$$$$$\            $$\ $$\   $$\                         
$$  __$$\           $$ |$$ |  $$ |                        
$$ |  $$ | $$$$$$\  $$ |$$ |  $$ | $$$$$$\  $$$$$$\$$$$\  
$$$$$$$\ | \____$$\ $$ |$$$$$$$$ |$$  __$$\ $$  _$$  _$$\ 
$$  __$$\  $$$$$$$ |$$ |$$  __$$ |$$ /  $$ |$$ / $$ / $$ |
$$ |  $$ |$$  __$$ |$$ |$$ |  $$ |$$ |  $$ |$$ | $$ | $$ |
$$$$$$$  |\$$$$$$$ |$$ |$$ |  $$ |\$$$$$$  |$$ | $$ | $$ |
\_______/  \_______|\__|\__|  \__| \______/ \__| \__| \__|
                                                          

EOF

APP_VERSION=$(grep -m 1 version pubspec.yaml | tr -s ' ' | cut -d' ' -f2 | cut -d'+' -f1 | tr -d '\n' | tr -d '\r')
WEB_DIR=/usr/share/nginx/html

if [ -d "${WEB_DIR}" ] && [ "$(ls -A ${WEB_DIR})" ] && [ "$(cat ${WEB_DIR}/.version)" = "$APP_VERSION" ]; then
    echo "Web directory already exists, is not empty and version is correct. Skipping build..."
else
    echo "API_URL=${API_URL}" > app.env

    # Install dependencies
    flutter pub get
    # Generate files (env file included from app.env)
    flutter pub run build_runner build --delete-conflicting-outputs
    # Build app
    flutter build web

    rm -rf ${WEB_DIR}/*
    cp -rf /app/build/web/* ${WEB_DIR}
    echo "${APP_VERSION}" > ${WEB_DIR}/.version
fi
rm -rf /app

# Move nginx conf
if [ "$USE_HTTPS" = true ]; then
    mv /confs/local_https.conf /etc/nginx/conf.d/default.conf
else
    mv /confs/local_http.conf /etc/nginx/conf.d/default.conf
fi
rm -rf /confs

exec /docker-entrypoint.sh nginx -g "daemon off;" "$@"
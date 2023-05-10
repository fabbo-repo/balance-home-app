#!/bin/sh

# Exit immediately if any of the following command exits 
# with a non-zero status
set -e

# Postgres checking
until psql $DATABASE_URL -c '\l'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 10
done
>&2 echo "Postgres is up - continuing"

chmod -R 777 /app

# Create log directory
touch /var/log/api/app.log
chmod 777 /var/log/api/app.log

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

APP_USER_UID=`id -u $APP_USER`

if [ "$USE_HTTPS" = true ]; then
    exec gunicorn --certfile=/certs/fullchain.pem --keyfile=/certs/privkey.pem \
        --bind 0.0.0.0:443 --user $APP_USER_UID --workers 1 --threads 4 \
        --timeout 0 $WSGI_APLICATION "$@"
else
    exec gunicorn --bind 0.0.0.0:80 --user $APP_USER_UID --workers 1 --threads 4 \
        --timeout 0 $WSGI_APLICATION "$@"
fi
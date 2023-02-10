#!/bin/sh

# Exit immediately if any of the following command exits 
# with a non-zero status
set -e

# Postgres checking
until psql $DATABASE_URL -c '\l'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 20
done
>&2 echo "Postgres is up - continuing"

# Create log directory
touch /var/log/balance_app/app.log
chmod 777 /var/log/balance_app/app.log

# Give permissions to media directory
chmod -R 777 /app/media

# Create backup directory
mkdir -p /var/backup
chmod 777 /var/backup

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
exec gunicorn --bind 0.0.0.0:8000 --user $APP_USER_UID --workers 1 --threads 8 --timeout 0 $WSGI_APLICATION "$@"
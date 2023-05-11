#!/bin/sh

# Exit immediately if any of the following command exits 
# with a non-zero status
set -e

# Postgres checking
until psql $DATABASE_URL -c '\l'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 5
done
>&2 echo "Postgres is up - continuing"

export DJANGO_CONFIGURATION=OnPremise

chmod -R 777 /app

# Create log directory
touch /var/log/api/app.log
chmod 777 /var/log/api/app.log

APP_USER_UID=`id -u $APP_USER`
exec celery -A core worker -l INFO --uid=$APP_USER_UID "$@"
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

# Create log directory
touch /var/log/balance_app/app.log
chmod 777 /var/log/balance_app/app.log

APP_USER_UID=`id -u $APP_USER`
exec celery -A core beat -l INFO --uid=$APP_USER_UID \
    --scheduler django_celery_beat.schedulers:DatabaseScheduler "$@"
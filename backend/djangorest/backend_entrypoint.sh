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

# Create backup directory
mkdir -p /var/backup
chmod 777 /var/backup

# Call collectstatic
python manage.py collectstatic --noinput

# Execute database migrations
if python manage.py migrate --check; then
    echo Migrations applied
else
    echo Applying migrations
    python manage.py migrate --noinput
fi

# Create superuser
export DJANGO_SUPERUSER_PASSWORD=$APP_SUPERUSER_PASSWORD
if python manage.py createsuperuser --email $APP_SUPERUSER_EMAIL --username $APP_SUPERUSER_USERNAME --no-input; then
    echo Superuser created
else
    echo Superuser already created, skipping
fi

# App commands
python manage.py balance_schedule_setup
python manage.py create_balance_models
python manage.py coin_schedule_setup
python manage.py create_coin_models
python manage.py users_schedule_setup
python manage.py inv_code_create --init

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
exec gunicorn --bind 0.0.0.0:8000 --user $APP_USER_UID --workers 1 --threads 8 --timeout 0 core.wsgi:application "$@"
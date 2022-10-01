#!/bin/sh

# Exit immediately if any of the following command exits 
# with a non-zero status
set -e

until psql $DATABASE_URL -c '\l'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 20
done

>&2 echo "Postgres is up - continuing"

# Create log directory
touch /var/log/balance_app/app.log
chmod 777 /var/log/balance_app/app.log

# Call collectstatic
/venv/bin/python manage.py collectstatic --noinput

# Execute database migrations
if  /venv/bin/python manage.py migrate --check; then
    echo Migrations applied
else
    echo Applying migrations
    /venv/bin/python manage.py migrate --noinput
fi

# Create superuser
if  /venv/bin/python manage.py createsuperuser --no-input; then
    echo Superuser created
else
    echo Superuser already created, skipping
fi

# App commands
/venv/bin/python manage.py balance_schedule_setup
/venv/bin/python manage.py create_balance_models
/venv/bin/python manage.py coin_schedule_setup
/venv/bin/python manage.py create_coin_models

cat << "EOF"



B)bbbb           l)L                                     H)    hh                                 A)aa                  
B)   bb           l)                                     H)    hh                                A)  aa                 
B)bbbb   a)AAAA   l)  a)AAAA  n)NNNN   c)CCCC e)EEEEE    H)hhhhhh  o)OOO   m)MM MMM  e)EEEEE    A)    aa p)PPPP  p)PPPP 
B)   bb   a)AAA   l)   a)AAA  n)   NN c)      e)EEEE     H)    hh o)   OO m)  MM  MM e)EEEE     A)aaaaaa p)   PP p)   PP
B)    bb a)   A   l)  a)   A  n)   NN c)      e)         H)    hh o)   OO m)  MM  MM e)         A)    aa p)   PP p)   PP
B)bbbbb   a)AAAA l)LL  a)AAAA n)   NN  c)CCCC  e)EEEE    H)    hh  o)OOO  m)      MM  e)EEEE    A)    aa p)PPPP  p)PPPP 
                                                                                                         p)      p)     
                                                                                                         p)      p)  


EOF

APP_USER_UID=`id -u $APP_USER`
exec /venv/bin/uwsgi --uid=$APP_USER_UID --http-auto-chunked --http-keepalive  "$@"

## Architecture Sample
~~~
djangorest/
    ├── app_1/
    │   ├── management/
    |   |   ├── __init__.py
    │   │   └── commands/
    |   |       ├── __init__.py
    |   |       ├── schedule_setup.py
    │   │       └── ... (This is optional)
    │   ├── templates/
    │   │   └── ... (This is optional)
    │   ├── migrations/
    │   │   └── ...
    |   ├── tests/
    |   │   ├── __init__.py
    |   │   ├── tests_1.py
    |   │   └── ...
    │   ├── api/
    |   │   ├── serializers.py  (This is optional)
    |   │   ├── serializers/
    │   |   │   ├── model1_serializers.py
    │   |   │   ├── ... (This is optional)
    │   |   │   └── model2_serializers.py
    |   │   ├── views.py  (This is optional)
    |   │   ├── views/
    │   |   │   ├── model1_views.py
    │   |   │   ├── ... (This is optional)
    │   |   │   └── model2_views.py
    |   │   └── urls.py
    │   ├── __init__.py
    │   ├── tasks.py
    │   ├── signals.py
    │   ├── schedule_setup.py
    │   ├── models.py
    │   ├── filters.py
    │   ├── notifications.py
    │   ├── apps.py
    │   └── admin.py
    ├── ...
    ├── app_2/
    │   ├── ...
    │   └── external_api_name_integration.py
    ├── external_api_name/
    │   ├── __init__.py
    │   ├── client.py
    │   └── django_client.py
    ├── core/
    |   ├── tests/
    |   │   ├── __init__.py
    |   │   ├── tests_settings.py
    |   │   └── ...
    |   ├── swagger/
    |   │   ├── __init__.py
    |   │   └── urls.py
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── celery.py
    │   ├── settings.py
    │   ├── urls.py
    │   ├── api_urls.py
    │   └── wsgi.py
    ├── templates/
    │   └── ... (This is optional)
    ├── media/
    │   └── ... (This is optional)
    ├── static/
    │   └── ... (This is optional)
    ├── manage.py
    └── db.sqlite3
~~~


## Useful commands

* Install project requirements:
~~~
pip install -r requirements.txt
~~~
* For the project creation it was used:
~~~
django-admin startproject core
~~~
* Create migrations:
~~~
python manage.py makemigrations
~~~
* Migrate changes (create tables in the specified database):
~~~
python manage.py migrate
~~~
* Create folder for static files:
~~~
python manage.py collectstatic
~~~
* Create an app:
~~~
python manage.py startapp app_1
~~~
* Create superuser:
~~~
python manage.py createsuperuser
~~~
* Change password:
~~~
python manage.py changepassword <username>
~~~
* Run server in debug mode:
~~~
python manage.py runserver 
~~~
* Export db data to a json file:
~~~
python manage.py dumpdata > db.json
~~~
* Import db data from a json file:
~~~
python manage.py loaddata db.json
~~~
* Launch testing:
~~~
python manage.py test
~~~
* Launch celery for development:
~~~
celery -A core worker -l INFO -P eventlet
~~~
> ***redis*** must be launched too
* Schedule periodic tasks:
~~~
python manage.py schedule_setup
~~~
* Create default coin types, revenue types and expense types:
~~~
python manage.py create_balance_models
~~~

## Environment Variables:

* APP_DOMAIN
* APP_PORT
* APP_DEBUG
* APP_TIME_ZONE
* APP_ALLOWED_HOSTS
* APP_EMAIL_HOST
* APP_EMAIL_PORT
* APP_EMAIL_HOST_USER
* APP_EMAIL_HOST_PASSWORD
* APP_CELERY_BROKER_URL
* APP_EMAIL_CODE_THRESHOLD
* APP_EMAIL_CODE_VALID
* DJANGO_SUPERUSER_USERNAME
* DJANGO_SUPERUSER_EMAIL
* DJANGO_SUPERUSER_PASSWORD
* DATABASE_URL
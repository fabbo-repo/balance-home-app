
## Architecture Sample
~~~
djangorest/
    ├── app_1/
    │   ├── templates/
    │   │   └── ... (This is optional)
    │   ├── migrations/
    │   │   └── ...
    │   ├── __init__.py
    │   ├── views.py
    │   ├── tasks.py
    │   ├── signals.py
    │   ├── models.py
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
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── celery.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    ├── templates/
    │   └── ... (This is optional)
    ├── tests/
    │   ├── __init__.py
    │   ├── tests_app_1.py
    │   └── ...
    ├── manage.py
    └── db.sqlite3
~~~


## Useful commands

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

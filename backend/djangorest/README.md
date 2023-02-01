# DRF Backend

## Architecture diagram

![Alt text](./diagrams/architecture.png?raw=true "")

## Directory tree example

~~~bash
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

## Environment Variables

| NAME                      | DESCRIPTION                                                |
| ------------------------- | ---------------------------------------------------------- |
| APP_DEBUG                 | Debug mode enabled (true|false)                            |
| APP_SECRET_KEY            | Secret key for criptography (optional)                     |
| APP_ALLOWED_HOSTS         | List of strings representing the allowed host/domain names |
| APP_CORS_HOSTS            | CORS allowed host/domain names                             |
| APP_EMAIL_HOST            | Email service host name                                    |
| APP_EMAIL_PORT            | Email service port                                         |
| APP_EMAIL_HOST_USER       | Email service authentication user                          |
| APP_EMAIL_HOST_PASSWORD   | Email service authentication password                      |
| APP_CELERY_BROKER_URL     | Celery url                                                 |
| APP_EMAIL_CODE_THRESHOLD  | Time to wait for a new email verification code generation  |
| APP_EMAIL_CODE_VALID      | Email verification code validity duration                  |
| APP_UNVERIFIED_USER_DAYS  | Days for a periodic deletion of unverified users           |
| APP_SUPERUSER_USERNAME    | Admin backend user name                                    |
| APP_SUPERUSER_EMAIL       | Admin backend user email                                   |
| APP_SUPERUSER_PASSWORD    | Admin backend user password                                |
| DATABASE_URL              | Databse url                                                |
| COIN_TYPE_CODES           | Coin type codes allowed (they have to be valid)            |
| DBBACKUP_GPG_RECIPIENT    | GPG key to encrypt backup (optional)                       |

## Useful commands

* Install project requirements:

~~~bash
pip install -r requirements.txt
~~~

* For the project creation it was used:

~~~bash
django-admin startproject core
~~~

* Create migrations:

~~~bash
python manage.py makemigrations
~~~

* Migrate changes (create tables in the specified database):

~~~bash
python manage.py migrate
~~~

* Check On Premise settings:

~~~bash
python manage.py check-on-premise
~~~

* Create folder for static files:

~~~bash
python manage.py collectstatic
~~~

* Create an app:

~~~bash
python manage.py startapp app_1
~~~

* Create superuser:

~~~bash
python manage.py createsuperuser
~~~

* Change password:

~~~bash
python manage.py changepassword <username>
~~~

* Run server in debug mode:

~~~bash
python manage.py runserver 
~~~

* Export db data to a json file:

~~~bash
python manage.py dumpdata > db.json
~~~

* Import db data from a json file:

~~~bash
python manage.py loaddata db.json
~~~

* Launch testing: (coverage included)

~~~bash
python manage.py test
~~~

* Generate html with coverage report:

~~~bash
coverage html
~~~

* Launch celery for development:

~~~bash
celery -A core worker -l INFO -P eventlet --scheduler django_celery_beat.schedulers:DatabaseScheduler
~~~

> ***redis*** must be launched too

* Schedule balance periodic tasks:

~~~bash
python manage.py balance_schedule_setup
~~~

* Create default revenue types and expense types:

~~~bash
python manage.py create_balance_models
~~~

* Schedule coin periodic tasks:

~~~bash
python manage.py coin_schedule_setup
~~~

* Create defined coin types:

~~~bash
python manage.py create_coin_models
~~~

* Schedule a task to delete all unverified users:

~~~bash
python manage.py users_schedule_setup
~~~

* Create **new** invitation code with 1 usage:

~~~bash
python manage.py inv_code_create --init
~~~

* Create invitation code with X usage:

~~~bash
python manage.py inv_code_create --usage X
~~~

* Generate locale messages files

~~~bash
django-admin makemessages --all --ignore=en
~~~

> Before executing it, a locale folder with all languages folders inside must be created

* Generate compiled messages

~~~bash
django-admin compilemessages --ignore=env
~~~

### [For simple backup](https://django-dbbackup.readthedocs.io/en/master/installation.html)

* Do backup

~~~bash
python manage.py dbbackup
~~~

* Restore backup

~~~bash
python manage.py dbrestore
~~~

### For encrypted backup

A GPG key must be generated first (use the command ```gpg --default-new-key-algo rsa4096 --gen-key```) and should be added as an environment variable with the name DBBACKUP_GPG_RECIPIENT.

* Do backup using GPG encryption

~~~bash
python manage.py dbbackup --encrypt
~~~

* Restore backup using GPG encryption

~~~bash
python manage.py dbrestore --decrypt
~~~

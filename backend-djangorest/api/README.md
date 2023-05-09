# DRF Backend

## Environment Variables

| NAME                      | DESCRIPTION                                                      |
| ------------------------- | ---------------------------------------------------------------- |
| APP_ALLOWED_HOSTS         | List of strings representing the allowed host/domain names       |
| APP_CORS_HOSTS            | CORS allowed host/domain names                                   |
| APP_EMAIL_HOST            | Email service host name                                          |
| APP_EMAIL_PORT            | Email service port                                               |
| APP_EMAIL_HOST_USER       | Email service authentication user                                |
| APP_EMAIL_HOST_PASSWORD   | Email service authentication password                            |
| APP_CELERY_BROKER_URL     | Celery url                                                       |
| APP_EMAIL_CODE_THRESHOLD  | Time to wait for a new email verification code generation        |
| APP_EMAIL_CODE_VALID      | Email verification code validity duration                        |
| APP_UNVERIFIED_USER_DAYS  | Days for a periodic deletion of unverified users                 |
| DATABASE_URL              | Databse endpoint                                                 |
| COIN_TYPE_CODES           | Coin type codes allowed (they have to be valid)                  |
| APP_FRONTEND_VERSION      | Minimum supported frontend version. Optional                     |
| APP_DISABLE_ADMIN_PANEL   | Disable admin panel url `/general/admin`. Default: ***False***   |
| APP_MINIO_ENDPOINT        | Minio api endpoint                                               |
| APP_MINIO_ACCESS_KEY      | Minio access key                                                 |
| APP_MINIO_SECRET_KEY      | Minio secret key                                                 |
| APP_MINIO_BUCKET_NAME     | Minio bucket name. Default: ***balhom-bucket***                  |

## Error Codes

| CODE  | DEFINITION                                                 | ENDPOINT                       |
| ----- | ---------------------------------------------------------- | ------------------------------ |
| 1     | No invitation code stored for an user                      | /api/v2/jwt                    |
| 2     | Unverified email for an user                               | /api/v2/jwt                    |
| 3     | Invalid refresh token                                      | /api/v2/jwt/refresh            |
| 4     | No active account found for specified refresh token        | /api/v2/jwt/refresh            |
| 5     | Username and email can not be the same                     | /api/v2/user                   |
| 6     | Code has already been sent, wait X seconds                 | /api/v2/email_code/send, /api/v2/user/password/reset/start |
| 7     | No code sent                                               | /api/v2/email_code/verify, /api/v2/user/password/reset/verify |
| 8     | Code is no longer valid                                    | /api/v2/email_code/verify, /api/v2/user/password/reset/verify |
| 9     | Invalid code                                               | /api/v2/email_code/verify, /api/v2/user/password/reset/verify |
| 10    | Only three codes can be sent per day                       | /api/v2/user/password/reset/start |
| 11    | New password must be different from old password           | /api/v2/user/password/change   |
| 12    | New password cannot match other profile data               | /api/v2/user/password/change   |

## Directory tree example

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
    │   ├── exceptions.py
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
    │   ├── exceptions.py
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

* Create static files:

~~~bash
python manage.py collectstatic
~~~

* Upload default media files to minio:

~~~bash
python manage.py collectmedia
~~~

* Launch celery for development:

~~~bash
celery -A core worker -l INFO -P eventlet --scheduler django_celery_beat.schedulers:DatabaseScheduler
~~~

> ***redis*** must be launched too

* Create invitation code with X usage:

~~~bash
python manage.py inv_code --usage X
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

from pathlib import Path
from configurations import Configuration
from django.utils.timezone import timedelta
import os
from django.utils.translation import gettext_lazy as _
import environ
from Crypto.PublicKey import RSA
import google.auth
from google.cloud import secretmanager as goole_secretmanager
from google.cloud import logging as google_logging
import io


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent
env = environ.Env(
    APP_DEBUG=(bool, os.getenv("APP_DEBUG", default=True)),
    APP_ALLOWED_HOSTS=(str, os.getenv("APP_ALLOWED_HOSTS", default='*')),
    APP_CORS_HOSTS=(str, os.getenv("APP_CORS_HOSTS")),
    DATABASE_URL=(str, os.getenv("DATABASE_URL",
                                 default='sqlite:///'+os.path.join(BASE_DIR, 'default.sqlite3'))),
    APP_EMAIL_CODE_THRESHOLD=(int, os.getenv(
        "APP_EMAIL_CODE_THRESHOLD", default=120)),
    APP_EMAIL_CODE_VALID=(int, os.getenv("APP_EMAIL_CODE_VALID", default=120)),
    APP_UNVERIFIED_USER_DAYS=(int, os.getenv(
        "APP_UNVERIFIED_USER_DAYS", default=2)),
    COIN_TYPE_CODES=(str, os.getenv("COIN_TYPE_CODES", default='EUR,USD')),
    DBBACKUP_GPG_RECIPIENT=(str, os.getenv("DBBACKUP_GPG_RECIPIENT")),
    APP_EMAIL_HOST=(str, os.getenv(
        "APP_EMAIL_HOST", default='smtp.gmail.com')),
    APP_EMAIL_PORT=(int, os.getenv("APP_EMAIL_PORT", default=587)),
    APP_EMAIL_HOST_USER=(str, os.getenv(
        "APP_EMAIL_HOST_USER", default='example@gmail.com')),
    APP_EMAIL_HOST_PASSWORD=(str, os.getenv(
        "APP_EMAIL_HOST_PASSWORD", default='password')),
    APP_CELERY_BROKER_URL=(str, os.getenv(
        "APP_CELERY_BROKER_URL", default="redis://localhost:6379/0")),
    GS_BUCKET_NAME=(str, os.getenv("GS_BUCKET_NAME")),
    USE_CLOUD_SQL_AUTH_PROXY=(bool, os.getenv(
        "USE_CLOUD_SQL_AUTH_PROXY", default=False)),
    USE_STACKDRIVER=(bool, os.getenv("USE_STACKDRIVER", default=False)),
)
# Attempt to load the Project ID into the environment, safely failing on error.
try:
    _, os.environ["GOOGLE_CLOUD_PROJECT"] = google.auth.default()
except google.auth.exceptions.DefaultCredentialsError:
    pass
# If a Proxy is used, then the secret manager service won't be used
if os.getenv("GOOGLE_CLOUD_PROJECT", None) and not env("USE_CLOUD_SQL_AUTH_PROXY"):
    project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
    client = goole_secretmanager.SecretManagerServiceClient()
    settings_name = os.getenv("SECRET_SETTINGS_NAME", "django_app_settings")
    name = f"projects/{project_id}/secrets/{settings_name}/versions/latest"
    payload = client.access_secret_version(name=name).payload.data.decode(
        "UTF-8"
    )
    env.read_env(io.StringIO(payload))


class Dev(Configuration):
    # Build paths inside the project like this: BASE_DIR / 'subdir'.
    BASE_DIR = Path(__file__).resolve().parent.parent

    private_key_file = os.path.join(BASE_DIR, 'private.key')
    public_key_file = os.path.join(BASE_DIR, 'public.key')

    if os.path.exists(private_key_file):
        print("* Using SECRET key from file")
        with open(private_key_file, 'rb') as reader:
            RSAkey = RSA.importKey(reader.read())
    else:
        print("* Generating SECRET key")
        RSAkey = RSA.generate(4096)
        with open(private_key_file, 'wb') as writer:
            print("* Generating PRIVATE key file")
            writer.write(RSAkey.exportKey())
        if not os.path.exists(public_key_file):
            with open(public_key_file, 'wb') as writer:
                print("* Generating PUBLIC key file")
                writer.write(RSAkey.publickey().exportKey())
    SECRET_KEY = RSAkey.exportKey()

    # True by default but have the option to set it false with an environment variable
    DEBUG = env('APP_DEBUG')

    ALLOWED_HOSTS = env('APP_ALLOWED_HOSTS').split(',')
    if env('APP_CORS_HOSTS'):
        CORS_ALLOW_ALL_ORIGINS = False
        CORS_ALLOWED_ORIGINS = env('APP_CORS_HOSTS').split(',')
    else:
        CORS_ALLOW_ALL_ORIGINS = True
    X_FRAME_OPTIONS = 'DENY'

    # Application definition
    INSTALLED_APPS = [
        'django.contrib.admin',
        'django.contrib.auth',
        'django.contrib.contenttypes',
        'django.contrib.sessions',
        'django.contrib.messages',
        'django.contrib.staticfiles',
        # Cors:
        "corsheaders",
        # Admin documentation:
        'django.contrib.admindocs',
        # Rest framework:
        'rest_framework',
        'django_filters',
        # Swager:
        'drf_yasg',
        # Task schedulling:
        'django_celery_results',
        'django_celery_beat',
        # Backup
        'dbbackup',
        # Custom apps:
        'core',
        'custom_auth',
        'balance',
        'revenue',
        'expense',
        'coin',
        'frontend_version'
    ]

    MIDDLEWARE = [
        "corsheaders.middleware.CorsMiddleware",
        'django.middleware.security.SecurityMiddleware',
        'django.contrib.sessions.middleware.SessionMiddleware',
        'django.middleware.locale.LocaleMiddleware',
        'django.middleware.common.CommonMiddleware',
        'django.middleware.csrf.CsrfViewMiddleware',
        'django.contrib.auth.middleware.AuthenticationMiddleware',
        'django.contrib.messages.middleware.MessageMiddleware',
        'django.middleware.clickjacking.XFrameOptionsMiddleware',
    ]

    ROOT_URLCONF = 'core.urls'

    CSRF_FAILURE_VIEW = 'core.views.csrf_failure'

    TEMPLATES = [
        {
            'BACKEND': 'django.template.backends.django.DjangoTemplates',
            'DIRS': [],
            'APP_DIRS': True,
            'OPTIONS': {
                'context_processors': [
                    'django.template.context_processors.debug',
                    'django.template.context_processors.request',
                    'django.contrib.auth.context_processors.auth',
                    'django.contrib.messages.context_processors.messages',
                ],
            },
        },
    ]

    # Database
    # https://docs.djangoproject.com/en/4.1/ref/settings/#databases
    DATABASES = {"default": env.db()}

    # Password validation
    # https://docs.djangoproject.com/en/4.1/ref/settings/#auth-password-validators

    AUTH_PASSWORD_VALIDATORS = [
        {
            'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
        },
        {
            'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
        },
        {
            'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
        },
        {
            'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
        },
    ]

    # Internationalization
    # https://docs.djangoproject.com/en/4.1/topics/i18n/

    LANGUAGE_CODE = 'en'
    LOCALE_PATHS = [
        BASE_DIR / 'locale/',
    ]
    LANGUAGES = (
        ('en', _('English')),
        ('es', _('Spanish')),
    )

    TIME_ZONE = "UTC"
    # Enables Django’s translation system
    USE_I18N = True
    # Django will display numbers and dates using the format of the current locale
    USE_L10N = True
    # Datetimes will be timezone-aware
    USE_TZ = True

    # Static files (CSS, JavaScript, Images)
    # https://docs.djangoproject.com/en/4.1/howto/static-files/
    STATIC_URL = 'static/'
    STATIC_ROOT = BASE_DIR / "static"
    MEDIA_URL = 'media/'
    MEDIA_ROOT = BASE_DIR / "media"

    # Default primary key field type
    # https://docs.djangoproject.com/en/4.1/ref/settings/#default-auto-field
    DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

    LOGGING = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "verbose": {
                "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
                "style": "{",
            },
        },
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "stream": "ext://sys.stdout",
                "formatter": "verbose",
            },
        },
        "root": {
            "handlers": ["console"],
            "level": "DEBUG",
        }
    }

    # Backup
    DBBACKUP_STORAGE = 'django.core.files.storage.FileSystemStorage'
    DBBACKUP_STORAGE_OPTIONS = {'location': '.'}

    # Django Rest Framework setting:
    REST_FRAMEWORK = {
        "DEFAULT_AUTHENTICATION_CLASSES": [
            "rest_framework_simplejwt.authentication.JWTAuthentication"
        ],
        "DEFAULT_PERMISSION_CLASSES": [
            "rest_framework.permissions.IsAuthenticated",
        ],
        "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
        "PAGE_SIZE": 10,
        "DEFAULT_FILTER_BACKENDS": [
            "django_filters.rest_framework.DjangoFilterBackend",
        ],
        "DEFAULT_THROTTLE_CLASSES": [
            "rest_framework.throttling.AnonRateThrottle",
            "rest_framework.throttling.UserRateThrottle"
        ],
        "DEFAULT_THROTTLE_RATES": {
            "anon": "30/minute",
            "user": "100/minute",
            "jwt_obtain_pair": "50/minute",
            "jwt_refresh": "100/minute",
        },
    }

    SIMPLE_JWT = {
        'UPDATE_LAST_LOGIN': True,
        "ACCESS_TOKEN_LIFETIME": timedelta(days=1),
        "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
        "ALGORITHM": 'RS256',
        "SIGNING_KEY": SECRET_KEY,
        "VERIFYING_KEY": RSAkey.publickey().exportKey(),
    }

    SWAGGER_SETTINGS = {
        "SECURITY_DEFINITIONS": {
            "Bearer": {
                "type": "apiKey",
                "name": "Authorization",
                "in": "header"
            },
        }
    }

    AUTH_USER_MODEL = "custom_auth.User"

    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

    CELERY_RESULT_BACKEND = "django-db"
    CELERY_BROKER_URL = env("APP_CELERY_BROKER_URL")

    # Time to wait for a new email verification code generation
    EMAIL_CODE_THRESHOLD = env('APP_EMAIL_CODE_THRESHOLD')
    # Email verification code validity duration
    EMAIL_CODE_VALID = env('APP_EMAIL_CODE_VALID')
    # Days for a periodic deletion of unverified users
    UNVERIFIED_USER_DAYS = env('APP_UNVERIFIED_USER_DAYS')

    COIN_TYPE_CODES = env('COIN_TYPE_CODES').split(',')


class OnPremise(Dev):
    DEBUG = False
    WSGI_APPLICATION = 'core.on_premise_wsgi.application'

    # Security headers
    CSRF_COOKIE_SECURE = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SESSION_COOKIE_SECURE = True
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

    # Backup
    DBBACKUP_STORAGE = 'django.core.files.storage.FileSystemStorage'
    DBBACKUP_STORAGE_OPTIONS = {'location': '/var/backup'}
    DBBACKUP_GPG_RECIPIENT = env('DBBACKUP_GPG_RECIPIENT')
    DBBACKUP_GPG_ALWAYS_TRUST = True

    if os.path.exists('/var/log/balance_app/app.log'):
        print("* Using file log")
        LOGGING = {
            "version": 1,
            "disable_existing_loggers": False,
            "formatters": {
                "verbose": {
                    "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
                    "style": "{",
                },
            },
            "handlers": {
                "logfile": {
                    "class": "logging.FileHandler",
                    "filename": "/var/log/balance_app/app.log",
                    "formatter": "verbose",
                },
            },
            "root": {
                "handlers": ["logfile"],
                "level": "ERROR",
            }
        }
    else:
        print("* Using console log")
        LOGGING = {
            "version": 1,
            "disable_existing_loggers": False,
            "formatters": {
                "verbose": {
                    "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
                    "style": "{",
                },
            },
            "handlers": {
                "console": {
                    "class": "logging.StreamHandler",
                    "stream": "ext://sys.stdout",
                    "formatter": "verbose",
                },
            },
            "root": {
                "handlers": ["console"],
                "level": "ERROR",
            }
        }

    SIMPLE_JWT = {
        'UPDATE_LAST_LOGIN': True,
        "ACCESS_TOKEN_LIFETIME": timedelta(hours=1),
        "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
        "ALGORITHM": 'RS256',
        "SIGNING_KEY": Dev.SECRET_KEY,
        "VERIFYING_KEY": Dev.RSAkey.publickey().exportKey()
    }

    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    # It is setup for gmail
    EMAIL_HOST = env('APP_EMAIL_HOST')
    EMAIL_USE_TLS = True
    EMAIL_PORT = env('APP_EMAIL_PORT')
    EMAIL_HOST_USER = env('APP_EMAIL_HOST_USER')
    EMAIL_HOST_PASSWORD = env('APP_EMAIL_HOST_PASSWORD')


class GCP(Dev):
    # Note:
    # GOOGLE_APPLICATION_CREDENTIALS env is needed
    DEBUG = False
    WSGI_APPLICATION = 'core.gcp_wsgi.application'

    # Security headers
    CSRF_COOKIE_SECURE = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SESSION_COOKIE_SECURE = True
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

    # Cloud SQL Database
    DATABASES = {"default": env.db()}
    # If the flag as been set, configure to use proxy
    if env("USE_CLOUD_SQL_AUTH_PROXY"):
        DATABASES["default"]["HOST"] = "cloudsql-proxy"
        DATABASES["default"]["PORT"] = 5432

    # Storage setup
    STATIC_ROOT = None
    MEDIA_ROOT = None
    STATICFILES_DIRS = []
    GS_BUCKET_NAME = env("GS_BUCKET_NAME")
    DEFAULT_FILE_STORAGE = "storages.backends.gcloud.GoogleCloudStorage"
    # Allow django-admin collectstatic to automatically put static files in GC bucket
    STATICFILES_STORAGE = "storages.backends.gcloud.GoogleCloudStorage"
    # "publicRead" to return a public url, non-expiring url. All other files return a signed (expiring) url.
    GS_DEFAULT_ACL = "publicRead"

    # Logging
    handlers = {
        "console": {
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stdout",
            "formatter": "verbose",
        }
    }
    if env('USE_STACKDRIVER'):
        # StackDriver setup
        # Logs Writer role needed (roles/logging.logWriter)
        google_logging_client = google_logging.Client()
        # Connects the logger to the root logging handler
        google_logging_client.setup_logging()
        handlers["stackdriver"] = {
            'class': 'google.cloud.logging.handlers.CloudLoggingHandler',
            'client': google_logging_client
        }
    LOGGING = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "verbose": {
                "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
                "style": "{",
            },
        },
        "handlers": handlers,
        "root": {
            "handlers": list(handlers.keys()),
            "level": "ERROR",
        }
    }

    SIMPLE_JWT = {
        'UPDATE_LAST_LOGIN': True,
        "ACCESS_TOKEN_LIFETIME": timedelta(hours=1),
        "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
        "ALGORITHM": 'RS256',
        "SIGNING_KEY": Dev.SECRET_KEY,
        "VERIFYING_KEY": Dev.RSAkey.publickey().exportKey()
    }

    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    # It is setup for gmail
    EMAIL_HOST = env('APP_EMAIL_HOST')
    EMAIL_USE_TLS = True
    EMAIL_PORT = env('APP_EMAIL_PORT')
    EMAIL_HOST_USER = env('APP_EMAIL_HOST_USER')
    EMAIL_HOST_PASSWORD = env('APP_EMAIL_HOST_PASSWORD')

from pathlib import Path
from configurations import Configuration
from django.utils.timezone import timedelta
import os
from django.utils.translation import gettext_lazy as _
import environ
from Crypto.PublicKey import RSA
from django.core.management.utils import get_random_secret_key


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent
env = environ.Env(
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
    APP_FRONTEND_VERSION=(str, os.getenv(
        "APP_FRONTEND_VERSION", default="1.3.0")),
    APP_DISABLE_ADMIN_PANEL=(bool, os.getenv(
        "APP_DISABLE_ADMIN_PANEL", default=False)),
    APP_EMAIL_HOST=(str, os.getenv(
        "APP_EMAIL_HOST", default='smtp.gmail.com')),
    APP_EMAIL_PORT=(int, os.getenv("APP_EMAIL_PORT", default=587)),
    APP_EMAIL_HOST_USER=(str, os.getenv(
        "APP_EMAIL_HOST_USER", default='example@gmail.com')),
    APP_EMAIL_HOST_PASSWORD=(str, os.getenv(
        "APP_EMAIL_HOST_PASSWORD", default='password')),
    APP_CELERY_BROKER_URL=(str, os.getenv(
        "APP_CELERY_BROKER_URL", default="redis://localhost:6379/0")),
    APP_MINIO_ENDPOINT=(str, os.getenv("APP_MINIO_ENDPOINT")),
    APP_MINIO_ACCESS_KEY=(str, os.getenv("APP_MINIO_ACCESS_KEY")),
    APP_MINIO_SECRET_KEY=(str, os.getenv("APP_MINIO_SECRET_KEY")),
    APP_MINIO_MEDIA_BUCKET_NAME=(str, os.getenv(
        "APP_MINIO_BUCKET_NAME", default="balhom-bucket")),
    APP_MINIO_STATIC_BUCKET_NAME=(str, os.getenv(
        "APP_MINIO_BUCKET_NAME", default="balhom-bucket")),
)


class Dev(Configuration):
    # Build paths inside the project like this: BASE_DIR / 'subdir'.
    private_key_file = os.path.join(BASE_DIR, 'private.key')
    public_key_file = os.path.join(BASE_DIR, 'public.key')

    if os.path.exists(private_key_file):
        print("* Using RSA key from file")
        with open(private_key_file, 'rb') as reader:
            RSAkey = RSA.importKey(reader.read())
    else:
        print("* Generating RSA key")
        RSAkey = RSA.generate(4096)
        with open(private_key_file, 'wb') as writer:
            print("* Generating PRIVATE key file")
            writer.write(RSAkey.exportKey())
        if not os.path.exists(public_key_file):
            with open(public_key_file, 'wb') as writer:
                print("* Generating PUBLIC key file")
                writer.write(RSAkey.publickey().exportKey())
    SECRET_KEY = get_random_secret_key()

    DEBUG = True

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
        # Cors
        "corsheaders",
        # Admin documentation
        'django.contrib.admindocs',
        # Rest framework
        'rest_framework',
        'django_filters',
        # Swager
        'drf_yasg',
        # Task schedulling
        'django_celery_results',
        'django_celery_beat',
        # Minio
        'minio_storage',
        # Custom apps
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
        "corsheaders.middleware.CorsPostCsrfMiddleware",
        'django.contrib.auth.middleware.AuthenticationMiddleware',
        'django.contrib.messages.middleware.MessageMiddleware',
        'django.middleware.clickjacking.XFrameOptionsMiddleware',
        #'core.middlewares.HeadersLoggingMiddleware',
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
        ('fr', _('French')),
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
        'EXCEPTION_HANDLER': 'core.exceptions.app_exception_handler'
    }

    SIMPLE_JWT = {
        'UPDATE_LAST_LOGIN': True,
        "ACCESS_TOKEN_LIFETIME": timedelta(days=1),
        "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
        "ALGORITHM": 'RS256',
        "SIGNING_KEY": RSAkey.exportKey(),
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

    APP_FRONTEND_VERSION = env('APP_FRONTEND_VERSION')

    APP_DISABLE_ADMIN_PANEL = env('APP_DISABLE_ADMIN_PANEL')


class OnPremise(Dev):
    DEBUG = False
    WSGI_APPLICATION = 'core.wsgi.application'

    # Security headers
    CSRF_COOKIE_SECURE = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SESSION_COOKIE_SECURE = True
    SECURE_SSL_REDIRECT = True
    SECURE_HSTS_SECONDS = 31536000  # 1 year
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True

    if os.path.exists('/var/log/api/app.log'):
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
                    "filename": "/var/log/api/app.log",
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
        "SIGNING_KEY": Dev.RSAkey.exportKey(),
        "VERIFYING_KEY": Dev.RSAkey.publickey().exportKey()
    }

    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    # It is setup for gmail
    EMAIL_HOST = env('APP_EMAIL_HOST')
    EMAIL_USE_TLS = True
    EMAIL_PORT = env('APP_EMAIL_PORT')
    EMAIL_HOST_USER = env('APP_EMAIL_HOST_USER')
    EMAIL_HOST_PASSWORD = env('APP_EMAIL_HOST_PASSWORD')

    if env('APP_MINIO_ENDPOINT'):
        STORAGES = {
            "default" : "core.minio_storage.MediaStorage",
            "staticfiles": "core.minio_storage.StaticStorage"
        }
        

        # REMOVE
        DEFAULT_FILE_STORAGE = 'minio_storage.storage.MinioMediaStorage'
        STATICFILES_STORAGE = 'minio_storage.storage.MinioMediaStorage'

        MINIO_STORAGE_ENDPOINT = env('APP_MINIO_ENDPOINT')
        MINIO_STORAGE_ACCESS_KEY = env('APP_MINIO_ACCESS_KEY')
        MINIO_STORAGE_SECRET_KEY = env('APP_MINIO_SECRET_KEY')
        MINIO_STORAGE_USE_HTTPS = True

        MINIO_STORAGE_MEDIA_BUCKET_NAME = env('APP_MINIO_MEDIA_BUCKET_NAME')
        MINIO_STORAGE_AUTO_CREATE_MEDIA_POLICY = 'READ_WRITE'
        MINIO_STORAGE_MEIDA_USE_PRESIGNED = True
        MINIO_STORAGE_MEIDA_URL_EXPIRY = 3600
        MINIO_STORAGE_AUTO_CREATE_MEDIA_BUCKET = True

        MINIO_STORAGE_STATIC_BUCKET_NAME = env('APP_MINIO_STATIC_BUCKET_NAME')
        MINIO_STORAGE_AUTO_CREATE_STATIC_BUCKET = True
        MINIO_STORAGE_AUTO_CREATE_STATIC_POLICY = 'READ_WRITE'
        MINIO_STORAGE_STATIC_USE_PRESIGNED = False

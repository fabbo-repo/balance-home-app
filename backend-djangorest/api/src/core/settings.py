from pathlib import Path
from configurations import Configuration
import os
from django.utils.translation import gettext_lazy as _
import environ
from django.core.management.utils import get_random_secret_key


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent
env = environ.Env(
    ALLOWED_HOSTS=(str, os.getenv("ALLOWED_HOSTS", default="*")),
    CORS_HOSTS=(str, os.getenv("CORS_HOSTS")),
    USE_HTTPS=(bool, os.getenv("USE_HTTPS", default=False)),
    DATABASE_URL=(
        str,
        os.getenv(
            "DATABASE_URL",
            default="sqlite:///" + os.path.join(BASE_DIR, "default.sqlite3"),
        ),
    ),
    EMAIL_CODE_THRESHOLD=(int, os.getenv("EMAIL_CODE_THRESHOLD", default=120)),
    EMAIL_CODE_VALID=(int, os.getenv("EMAIL_CODE_VALID", default=120)),
    UNVERIFIED_USER_DAYS=(int, os.getenv("UNVERIFIED_USER_DAYS", default=2)),
    COIN_TYPE_CODES=(str, os.getenv("COIN_TYPE_CODES", default="EUR,USD")),
    FRONTEND_VERSION=(str, os.getenv("FRONTEND_VERSION", default="1.4.0")),
    DISABLE_ADMIN_PANEL=(bool, os.getenv(
        "DISABLE_ADMIN_PANEL", default=False)),
    EMAIL_HOST=(str, os.getenv("EMAIL_HOST", default="smtp.gmail.com")),
    EMAIL_PORT=(int, os.getenv("EMAIL_PORT", default=587)),
    EMAIL_HOST_USER=(
        str,
        os.getenv("EMAIL_HOST_USER", default="example@gmail.com"),
    ),
    EMAIL_HOST_PASSWORD=(
        str,
        os.getenv("EMAIL_HOST_PASSWORD", default="password"),
    ),
    CELERY_BROKER_URL=(
        str,
        os.getenv("CELERY_BROKER_URL", default="redis://localhost:6379/0"),
    ),
    MINIO_ENDPOINT=(str, os.getenv("MINIO_ENDPOINT")),
    MINIO_ACCESS_KEY=(str, os.getenv("MINIO_ACCESS_KEY")),
    MINIO_SECRET_KEY=(str, os.getenv("MINIO_SECRET_KEY")),
    MINIO_MEDIA_BUCKET_NAME=(
        str,
        os.getenv("MINIO_MEDIA_BUCKET_NAME", default="balhom-static-bucket"),
    ),
    MINIO_STATIC_BUCKET_NAME=(
        str,
        os.getenv("MINIO_STATIC_BUCKET_NAME", default="balhom-media-bucket"),
    ),
    KEYCLOAK_ENDPOINT=(str, os.getenv(
        "KEYCLOAK_ENDPOINT", default="localhost:39080")),
    KEYCLOAK_CLIENT_ID=(
        str,
        os.getenv("KEYCLOAK_CLIENT_ID", default="balhom-api"),
    ),
    KEYCLOAK_CLIENT_SECRET=(
        str,
        os.getenv("KEYCLOAK_CLIENT_SECRET", default="secret"),
    ),
    KEYCLOAK_REALM=(
        str,
        os.getenv("KEYCLOAK_REALM", default="balhom-realm"),
    ),
)
USE_HTTPS = env("USE_HTTPS")


class Dev(Configuration):
    SECRET_KEY = get_random_secret_key()

    DEBUG = True

    ALLOWED_HOSTS = env("ALLOWED_HOSTS").split(",")
    if env("CORS_HOSTS"):
        CORS_ALLOW_ALL_ORIGINS = False
        CORS_ALLOWED_ORIGINS = env("CORS_HOSTS").split(",")
    else:
        CORS_ALLOW_ALL_ORIGINS = True
    X_FRAME_OPTIONS = "DENY"

    # Application definition
    INSTALLED_APPS = [
        "django.contrib.admin",
        "django.contrib.auth",
        "django.contrib.contenttypes",
        "django.contrib.sessions",
        "django.contrib.messages",
        "django.contrib.staticfiles",
        # Cors
        "corsheaders",
        # Rest framework
        "rest_framework",
        "django_filters",
        # Swager
        "drf_yasg",
        # Task schedulling
        "django_celery_results",
        "django_celery_beat",
        # Django storage provider drivers
        "storages",
        # Custom apps
        "core",
        "custom_auth",
        "balance",
        "revenue",
        "expense",
        "coin",
        "frontend_version",
    ]

    MIDDLEWARE = [
        "corsheaders.middleware.CorsMiddleware",
        "django.middleware.security.SecurityMiddleware",
        "django.contrib.sessions.middleware.SessionMiddleware",
        "django.middleware.locale.LocaleMiddleware",
        "django.middleware.common.CommonMiddleware",
        "django.middleware.csrf.CsrfViewMiddleware",
        "django.contrib.auth.middleware.AuthenticationMiddleware",
        "django.contrib.messages.middleware.MessageMiddleware",
        "django.middleware.clickjacking.XFrameOptionsMiddleware",
        # 'core.middlewares.HeadersLoggingMiddleware',
    ]

    ROOT_URLCONF = "core.urls"

    CSRF_FAILURE_VIEW = "core.views.csrf_failure"

    TEMPLATES = [
        {
            "BACKEND": "django.template.backends.django.DjangoTemplates",
            "DIRS": [],
            "APP_DIRS": True,
            "OPTIONS": {
                "context_processors": [
                    "django.template.context_processors.debug",
                    "django.template.context_processors.request",
                    "django.contrib.auth.context_processors.auth",
                    "django.contrib.messages.context_processors.messages",
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
            "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
        },
        {
            "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        },
        {
            "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
        },
        {
            "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
        },
    ]

    # Internationalization
    # https://docs.djangoproject.com/en/4.1/topics/i18n/

    LANGUAGE_CODE = "en"
    LOCALE_PATHS = [
        BASE_DIR / "locale/",
    ]
    LANGUAGES = (
        ("en", _("English")),
        ("es", _("Spanish")),
        ("fr", _("French")),
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
    STATIC_URL = "static/"
    STATIC_ROOT = BASE_DIR / "static"
    MEDIA_URL = "media/"
    MEDIA_ROOT = BASE_DIR / "media"

    # Default primary key field type
    # https://docs.djangoproject.com/en/4.1/ref/settings/#default-auto-field
    DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

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
        },
    }

    AUTHENTICATION_BACKENDS = (
        'keycloak_client.backend.KeycloakAuthenticationBackend',
    )

    # Django Rest Framework setting:
    REST_FRAMEWORK = {
        "DEFAULT_AUTHENTICATION_CLASSES": [
            'keycloak_client.authentication.KeycloakAuthentication',
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
            "rest_framework.throttling.UserRateThrottle",
        ],
        "DEFAULT_THROTTLE_RATES": {
            "anon": "50/minute",
            "user": "5000/minute",
        },
        "EXCEPTION_HANDLER": "core.exceptions.app_exception_handler",
    }

    # Keycloak config
    KEYCLOAK_CLIENT_ID = env('KEYCLOAK_CLIENT_ID')
    KEYCLOAK_CLIENT_SECRET = env('KEYCLOAK_CLIENT_SECRET')
    KEYCLOAK_ENDPOINT = env('KEYCLOAK_ENDPOINT')
    KEYCLOAK_REALM = env('KEYCLOAK_REALM')

    SWAGGER_SETTINGS = {
        "SECURITY_DEFINITIONS": {
            "Bearer": {"type": "apiKey", "name": "Authorization", "in": "header"},
        }
    }

    AUTH_USER_MODEL = "custom_auth.User"

    EMAIL_BACKEND = "django.core.mail.backends.console.EmailBackend"

    CELERY_RESULT_BACKEND = "django-db"
    CELERY_BROKER_URL = env("CELERY_BROKER_URL")

    # Time to wait for a new email verification code generation
    EMAIL_CODE_THRESHOLD = env("EMAIL_CODE_THRESHOLD")
    # Email verification code validity duration
    EMAIL_CODE_VALID = env("EMAIL_CODE_VALID")
    # Days for a periodic deletion of unverified users
    UNVERIFIED_USER_DAYS = env("UNVERIFIED_USER_DAYS")

    COIN_TYPE_CODES = env("COIN_TYPE_CODES").split(",")

    FRONTEND_VERSION = env("FRONTEND_VERSION")

    DISABLE_ADMIN_PANEL = env("DISABLE_ADMIN_PANEL")


class OnPremise(Dev):
    DEBUG = False
    WSGI_APPLICATION = "core.wsgi.application"

    # Security headers
    if USE_HTTPS:
        CSRF_COOKIE_SECURE = True
        SESSION_COOKIE_SECURE = True
        SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
        SECURE_SSL_REDIRECT = True
        SECURE_HSTS_SECONDS = 31536000  # 1 year
        SECURE_HSTS_INCLUDE_SUBDOMAINS = True
        SECURE_HSTS_PRELOAD = True

    if os.path.exists("/var/log/api/app.log"):
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
            },
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
            },
        }

    EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
    # It is setup for gmail
    EMAIL_HOST = env("EMAIL_HOST")
    EMAIL_USE_TLS = True
    EMAIL_PORT = env("EMAIL_PORT")
    EMAIL_HOST_USER = env("EMAIL_HOST_USER")
    EMAIL_HOST_PASSWORD = env("EMAIL_HOST_PASSWORD")

    MINIO_STORAGE_ENDPOINT = env("MINIO_ENDPOINT")
    if MINIO_STORAGE_ENDPOINT:
        STORAGES = {
            "default": {"BACKEND": "core.storage_backends.MinioMediaStorage"},
            "staticfiles": {"BACKEND": "core.storage_backends.MinioStaticStorage"},
        }
        if USE_HTTPS:
            AWS_S3_USE_SSL = True
            AWS_S3_ENDPOINT_URL = "https://" + env("MINIO_ENDPOINT")
        else:
            AWS_S3_ENDPOINT_URL = "http://" + env("MINIO_ENDPOINT")
        AWS_ACCESS_KEY_ID = env("MINIO_ACCESS_KEY")
        AWS_SECRET_ACCESS_KEY = env("MINIO_SECRET_KEY")
        AWS_S3_OBJECT_PARAMETERS = {
            "CacheControl": "max-age=86400",
        }
        AWS_DEFAULT_ACL = None

        MINIO_STATIC_BUCKET_NAME = env("MINIO_STATIC_BUCKET_NAME")
        MINIO_MEDIA_BUCKET_NAME = env("MINIO_MEDIA_BUCKET_NAME")
        MINIO_STORAGE_ACCESS_KEY = env("MINIO_ACCESS_KEY")
        MINIO_STORAGE_SECRET_KEY = env("MINIO_SECRET_KEY")

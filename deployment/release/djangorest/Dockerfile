FROM python:3.9.14

# Create a group and user to run our app
ENV APP_USER=balance_app_user
RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -g ${APP_USER} ${APP_USER}

# Install packages needed to run your application (not build deps):
#   mime-support -- for mime types when serving static files
#   postgresql-client -- for running database commands
# We need to recreate the /usr/share/man/man{1..8} directories first because
# they were clobbered by a parent image.
RUN set -ex \
    && RUN_DEPS=" \
    libpcre3 \
    mime-support \
    postgresql-client \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
    && rm -rf /var/lib/apt/lists/*

# Copy in your requirements file
ADD requirements.txt /requirements.txt

# Install build deps, then remove unneeded build deps all in a single step.
# Correct the path to your production requirements file, if needed.
RUN set -ex \
    && BUILD_DEPS=" \
    build-essential \
    libpcre3-dev \
    libpq-dev \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

# Run `pip install`
RUN python3 -m venv /venv \
    && /venv/bin/pip install -U pip \
    && LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "/venv/bin/pip install --no-cache-dir -r /requirements.txt"

ENV PYTHONUNBUFFERED 1

# Copy your application code to the container 
# Note: create a .dockerignore file if any large files or directories should be excluded
RUN mkdir /code/
WORKDIR /code/
ADD . /code/

# uWSGI will listen on this port
EXPOSE 8000

# Add any custom, static environment variables needed by Django or your settings file here:
#ENV DJANGO_SETTINGS_MODULE=myapp.settings
ENV DJANGO_CONFIGURATION=Prod

# uWSGI configuration (customize as needed):
ENV UWSGI_VIRTUALENV=/venv UWSGI_WSGI_FILE=core/wsgi.py UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_WORKERS=2 UWSGI_THREADS=4 UWSGI_LAZY_APPS=1 UWSGI_WSGI_ENV_BEHAVIOR=holy

# Log directory:
RUN mkdir -p /var/log/balance_app
RUN chmod 700 -R /var/log/balance_app
RUN chown ${APP_USER}:${APP_USER} -R /var/log/balance_app

# Make migrations
RUN /venv/bin/python manage.py makemigrations

# Change to a non-root user
#USER ${APP_USER}:${APP_USER}

RUN chmod +x /code/app_entrypoint.sh
ENTRYPOINT ["/code/app_entrypoint.sh"]

# Start uWSGI
#CMD ["/venv/bin/uwsgi", "--http-auto-chunked", "--http-keepalive", "--uid", "${id -u ${APP_USER}}"]
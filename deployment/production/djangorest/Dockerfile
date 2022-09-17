FROM python:3.9.14

# Create a group and user to run our app
ARG APP_USER=balance_app_user
RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -g ${APP_USER} ${APP_USER}

# Copy in your requirements file
ADD requirements.txt /requirements.txt

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

# Call collectstatic
# Note: Customize the following line with the minimal environment variables needed for manage.py to run
#RUN DATABASE_URL='' python manage.py collectstatic --noinput
RUN DATABASE_URL='' python manage.py collectstatic --noinput

# Add any custom, static environment variables needed by Django or your settings file here:
#ENV DJANGO_SETTINGS_MODULE=myapp.settings

# uWSGI configuration (customize as needed):
ENV UWSGI_VIRTUALENV=/venv UWSGI_WSGI_FILE=core/wsgi.py UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_WORKERS=2 UWSGI_THREADS=4 UWSGI_LAZY_APPS=1 UWSGI_WSGI_ENV_BEHAVIOR=holy

# Change to a non-root user
USER ${APP_USER}:${APP_USER}

# Make migrations
RUN python3 manage.py makemigrations

# Start uWSGI
CMD ["/venv/bin/uwsgi", "--http-auto-chunked", "--http-keepalive"]
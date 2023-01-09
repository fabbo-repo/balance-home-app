FROM python:3.10-buster

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

# Install Poetry
#RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/etc/poetry python3 -
#ENV PATH="/etc/poetry:${PATH}"

# Copy dependency files
#COPY pyproject.toml /
#COPY poetry.lock /
COPY requirements.txt /

# Install build deps, then remove unneeded build deps all in a single step.
# Correct the path to your production requirements file, if needed.
RUN set -ex \
    && BUILD_DEPS=" \
    build-essential \
    libpq-dev \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

# Add dependencies from requirements
#RUN cat requirements.txt | xargs poetry add
#RUN poetry lock
# Install dependencies
#RUN poetry install
RUN pip install -r requirements.txt

ENV PYTHONUNBUFFERED 1

# Copy your application code to the container 
# Note: create a .dockerignore file if any large files or directories should be excluded
RUN mkdir /app/
WORKDIR /app/
ADD . /app/

# uWSGI will listen on this port
EXPOSE 8000

# Add any custom, static environment variables needed by Django or your settings file here:
#ENV DJANGO_SETTINGS_MODULE=myapp.settings
ENV DJANGO_CONFIGURATION=Prod

# Log directory:
RUN mkdir -p /var/log/balance_app

# Make migrations
RUN python manage.py makemigrations

# Compile translations
RUN django-admin compilemessages --ignore=env

# Change to a non-root user
#USER ${APP_USER}:${APP_USER}

# Entrypoint permissions
RUN chmod a+x /app/backend_entrypoint.sh
RUN chmod a+x /app/celery_entrypoint.sh

RUN ls -l /app

ENTRYPOINT ["/app/backend_entrypoint.sh"]

# Start uWSGI
#CMD ["/venv/bin/uwsgi", "--http-auto-chunked", "--http-keepalive", "--uid", "${id -u ${APP_USER}}"]
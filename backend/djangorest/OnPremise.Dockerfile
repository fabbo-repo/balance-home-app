FROM python:3.10-slim

# Create a group and user to run our app
ENV APP_USER=balance_app_user
RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -g ${APP_USER} ${APP_USER}

# Install gettext library and psql client to check whether pg db is available
RUN set -ex \
    && BUILD_DEPS=" \
    gettext \
    postgresql-client \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
#RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/etc/poetry python3 -
#ENV PATH="/etc/poetry:${PATH}"

# Copy dependency files
#COPY pyproject.toml /
#COPY poetry.lock /
COPY src/requirements.txt /

# Add dependencies from requirements
#RUN cat requirements.txt | xargs poetry add
#RUN poetry lock
# Install dependencies
#RUN poetry install
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /requirements.txt
    
ENV PATH="/py/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Copy your application code to the container 
# Note: create a .dockerignore file if any large files or directories should be excluded
RUN mkdir /app/
WORKDIR /app/
ADD src /app/

# uWSGI will listen on this port
EXPOSE 8000

# Add any custom, static environment variables needed by Django or your settings file here:
#ENV DJANGO_SETTINGS_MODULE=myapp.settings
ENV DJANGO_CONFIGURATION=OnPremise
ENV WSGI_APLICATION="core.on_premise_wsgi:application"

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

ENTRYPOINT ["/app/backend_entrypoint.sh"]
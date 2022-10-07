"""
WSGI config for core project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/wsgi/
"""

import os


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')

os.environ.setdefault("DJANGO_CONFIGURATION", "Prod")

# Trying to import Django Configuration’s get_wsgi_application 
# will fail if DJANGO_CONFIGURATION is not yet defined
from configurations.wsgi import get_wsgi_application

application = get_wsgi_application()

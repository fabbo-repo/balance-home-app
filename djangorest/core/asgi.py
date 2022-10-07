"""
ASGI config for core project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/asgi/
"""

import os

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')

os.environ.setdefault("DJANGO_CONFIGURATION", "Prod")

# Trying to import Django Configuration’s get_asgi_application 
# will fail if DJANGO_CONFIGURATION is not yet defined
from configurations.asgi import get_asgi_application

application = get_asgi_application()

"""Imports."""
import logging
from django.contrib.auth.backends import ModelBackend
from django.core.exceptions import ObjectDoesNotExist
from custom_auth.models import User
from keycloak_client.django_client import get_keycloak_client

logger = logging.getLogger(__name__)


class KeycloakAuthenticationBackend(ModelBackend):
    """
    Authenticate with keycloak.
    """

    def authenticate(self, request, username=None, password=None, **kwargs):
        """Authenticate backend."""
        keycloak_client = get_keycloak_client()
        res = keycloak_client.authenticate_user(username, password)
        if res:
            try:
                user = User.objects.get(email=username)
            except ObjectDoesNotExist:
                logger.debug("User does not exists")
                return None
            return user
        logger.debug("Wrong credentials")
        return None

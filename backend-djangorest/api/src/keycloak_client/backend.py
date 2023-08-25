"""
Provides a Keycloak authentication backend class for django.
"""
import logging
from django.contrib.auth.backends import ModelBackend
from django.core.exceptions import ObjectDoesNotExist
from app_auth.models import User
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
                keycloak_id = keycloak_client.get_user_id(email=username)
                user = User.objects.get(keycloak_id=keycloak_id)
            except ObjectDoesNotExist:
                logger.debug("User does not exists")
                return None
            return user
        logger.debug("Wrong credentials")
        return None

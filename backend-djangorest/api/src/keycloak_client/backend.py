from django.contrib.auth.backends import BaseBackend
from custom_auth.models import User
from keycloak_client.django_client import get_keycloak_client
import logging

logger = logging.getLogger(__name__)


class KeycloakAuthenticationBackend(BaseBackend):
    """
    Authenticate with keycloak.
    """

    def authenticate(self, request, username=None, password=None) -> User | None:
        keycloak_client = get_keycloak_client()
        res = keycloak_client.authenticate_user(username, password)
        if res:
            try:
                user = User.objects.get(email=username)
            except User.DoesNotExist:
                logger.debug("User does not exists")
                return None
            return user
        logger.debug("Wrong credentials")
        return None

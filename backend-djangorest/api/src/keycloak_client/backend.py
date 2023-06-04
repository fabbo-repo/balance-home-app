from django.conf import settings
from django.contrib.auth.backends import BaseBackend
from django.contrib.auth.models import User
from keycloak_client.django_client import get_keycloak_client


class KeycloakAuthenticationBackend(BaseBackend):
    """
    Authenticate with keycloak.
    """

    def authenticate(self, request, email=None, password=None) -> User | None:
        keycloak_client = get_keycloak_client()
        res = keycloak_client.authenticate_user(email, password)
        if res:
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                user = User(email=email)
                user.save()
            return user
        return None

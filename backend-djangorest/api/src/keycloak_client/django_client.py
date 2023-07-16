"""Cache Keycloak client."""
from functools import lru_cache
from keycloak_client.abstract_keycloak import AbstractKeycloak
from keycloak_client.keycloak_client import KeycloakClient
from keycloak_client.keycloak_client_mock import KeycloakClientMock
from django.conf import settings

@lru_cache
def get_keycloak_client() -> AbstractKeycloak:
    """Create an instance of a KeycloakClient using singleton pattern."""
    if settings.TESTING:
        return KeycloakClientMock()
    return KeycloakClient()

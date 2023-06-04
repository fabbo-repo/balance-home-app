from django.conf import settings
from functools import lru_cache
from keycloak.client import KeycloakClient


@lru_cache
def get_keycloak_client() -> KeycloakClient:
    """Create an instance of a KeycloakClient using singleton pattern."""
    return KeycloakClient()

import logging
from typing import Literal
from jose import JWTError
import requests
from django.conf import settings
from keycloak import KeycloakOpenID

logger = logging.getLogger(__name__)

KEYCLOAK_URL = "https://" if settings.USE_HTTPS else "http://" + \
    settings.KEYCLOAK_ENDPOINT


class KeycloakClient:

    def __init__(self):
        self.keycloak_openid = KeycloakOpenID(
            server_url=KEYCLOAK_URL,
            client_id=settings.KEYCLOAK_CLIENT_ID,
            client_secret_key=settings.KEYCLOAK_CLIENT_SECRET,
            realm_name=settings.KEYCLOAK_REALM
        )
        self.public_key = "-----BEGIN PUBLIC KEY-----\n" + \
            self.keycloak_openid.public_key() + "\n-----END PUBLIC KEY-----"

    def verify_access_token(self, access_token: str) -> tuple[Literal[False], dict]:
        """Tries to decode `acces_token` using keycloak's public key."""
        options = {"verify_signature": True,
                   "verify_aud": True, "verify_exp": True}
        try:
            res = self.keycloak_openid.decode_token(
                access_token, key=self.public_key, options=options)
            return (True, res)
        except JWTError:
            return (False, {})
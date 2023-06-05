import logging
from jose import JWTError
from django.conf import settings
from keycloak import (
    KeycloakOpenID,
    KeycloakAdmin,
    KeycloakOpenIDConnection,
    KeycloakPostError,
)

logger = logging.getLogger(__name__)

KEYCLOAK_URL = (
    "https://" if settings.USE_HTTPS else "http://" + settings.KEYCLOAK_ENDPOINT
)


class KeycloakClient:
    def __init__(self):
        logger.debug(
            "Using:\n{}\n{}\n{}\n{}".format(
                KEYCLOAK_URL,
                settings.KEYCLOAK_CLIENT_ID,
                settings.KEYCLOAK_CLIENT_SECRET,
                settings.KEYCLOAK_REALM,
            )
        )
        # OpenIDClient
        self.keycloak_openid = KeycloakOpenID(
            server_url=KEYCLOAK_URL,
            client_id=settings.KEYCLOAK_CLIENT_ID,
            client_secret_key=settings.KEYCLOAK_CLIENT_SECRET,
            realm_name=settings.KEYCLOAK_REALM,
            verify=settings.USE_HTTPS,
        )
        self.public_key = (
            "-----BEGIN PUBLIC KEY-----\n"
            + self.keycloak_openid.public_key()
            + "\n-----END PUBLIC KEY-----"
        )
        # Admin client
        keycloak_connection = KeycloakOpenIDConnection(
            server_url=KEYCLOAK_URL,
            client_id=settings.KEYCLOAK_CLIENT_ID,
            client_secret_key=settings.KEYCLOAK_CLIENT_SECRET,
            realm_name=settings.KEYCLOAK_REALM,
            verify=settings.USE_HTTPS,
        )
        self.keycloak_admin = KeycloakAdmin(connection=keycloak_connection)

    def verify_access_token(self, access_token: str) -> tuple[bool, dict]:
        """Tries to decode `acces_token` using keycloak's public key."""
        options = {"verify_signature": True,
                   "verify_aud": True, "verify_exp": True}
        try:
            res = self.keycloak_openid.decode_token(
                access_token, key=self.public_key, options=options
            )
            return (True, res)
        except JWTError:
            return (False, {})

    def authenticate_user(self, email: str, password: str) -> dict | None:
        """Tries to authenticate an user with email and password."""
        try:
            return self.keycloak_openid.token(email, password)
        except KeycloakPostError as err:
            logger.debug(str(err))
            return None

    def get_user_info(self, email: str):
        users = self.keycloak_admin.get_users({"email": email})
        return None if not users else list(users)[0]

    def send_verify_email(self, email: str):
        user = self.get_user_info(email)
        if user:
            self.keycloak_admin.send_verify_email(user_id=user["id"])

    def send_reset_password_email(self, email: str):
        user = self.get_user_info(email)
        if user:
            self.keycloak_admin.send_update_account(
                user_id=user["id"],
                payload=["UPDATE_PASSWORD"]
            )

    def change_user_password(self, email: str, password: str):
        user = self.get_user_info(email)
        if user:
            self.keycloak_admin.set_user_password(
                user_id=user["id"],
                password=password,
                temporary=False
            )

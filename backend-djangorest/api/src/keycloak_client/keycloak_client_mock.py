"""
Provides a Keycloak Test client class.
"""
from django.utils.timezone import datetime


class KeycloakClientMock:

    def __init__(self):
        self.keycloak_id = "1234"
        self.is_deleted = False
        self.access_token = "test.access.token"
        self.refresh_token = "test.refresh.token"
        self.email = "test@mail.com"
        self.email_for_conflict = "conflict@mail.com"
        self.username = "test"
        self.updated_username = "test"
        self.password = "password&1234"
        self.updated_password = "password&1234"
        self.email_verified = True
        self.locale = "en"
        self.updated_locale = "en"
        self.user_enabled = True
        self.reset_password_mail_sent = False

    def verify_access_token(self, access_token: str) -> tuple[bool, dict]:
        """
        Tries to decode a "test.access.token" `acces_token`.
        """
        if access_token == self.access_token:
            return (True, {
                "sub": self.keycloak_id
            })
        return (False, {})

    def authenticate_user(self, email: str, password: str) -> dict | None:
        """
        Tries to authenticate an user with "test@mail.com" email 
        and "password" password.
        """
        if email == self.email and password == self.password:
            return {
                "access_token": self.access_token,
                "refresh_token": self.refresh_token
            }
        return None

    def get_user_info_by_id(self, keycloak_id: str) -> dict | None:
        """
        Get user info by "1234" keycloak id.
        """
        if keycloak_id == self.keycloak_id:
            return {
                "id": self.keycloak_id,
                "createdTimestamp": 1688991767048,
                "username": self.email,
                "enabled": self.user_enabled,
                "totp": False,
                "emailVerified": self.email_verified,
                "firstName": self.username,
                "lastName": "",
                "email": self.email,
                "attributes": {
                    "locale": [
                        self.locale
                    ]
                },
                "disableableCredentialTypes": [],
                "requiredActions": [],
                "notBefore": 0,
                "access": {
                    "manageGroupMembership": True,
                    "view": True,
                    "mapRoles": True,
                    "impersonate": False,
                    "manage": True
                }
            }
        return None

    def get_user_info_by_email(self, email: str) -> dict | None:
        """Get user info by "test@mail.com" email."""
        if email == self.email:
            return {
                "id": self.keycloak_id,
                "createdTimestamp": 1688991767048,
                "username": self.email,
                "enabled": self.user_enabled,
                "totp": False,
                "emailVerified": self.email_verified,
                "firstName": self.username,
                "lastName": "",
                "email": self.email,
                "attributes": {
                    "locale": [
                        self.locale
                    ]
                },
                "disableableCredentialTypes": [],
                "requiredActions": [],
                "notBefore": 0,
                "access": {
                    "manageGroupMembership": True,
                    "view": True,
                    "mapRoles": True,
                    "impersonate": False,
                    "manage": True
                }
            }
        return None

    def get_user_sessions(self, keycloak_id: str) -> list | None:
        """Get test user sessions."""
        if keycloak_id == self.keycloak_id:
            return [
                {
                    "id": "12345",
                    "username": self.email,
                    "userId": self.keycloak_id,
                    "ipAddress": "192.168.0.1",
                    "start": 1689274713000,
                    "lastAccess": 1689274713000,
                    "rememberMe": True,
                    "clients": {
                        "f8b10": "test-client"
                    }
                },
                {
                    "id": "123456",
                    "username": self.email,
                    "userId": self.keycloak_id,
                    "ipAddress": "192.168.0.1",
                    "start": 1689276614000,
                    "lastAccess": 1689276614000,
                    "rememberMe": False,
                    "clients": {
                        "f8b10": "test-client"
                    }
                }
            ]
        return None

    def get_user_last_login(self, keycloak_id: str) -> datetime | None:
        """Get now date time as user last login."""
        if keycloak_id == self.keycloak_id:
            return datetime.now()
        return None

    def get_user_id(self, email: str) -> str | None:
        """Get user keycloak id."""
        user = self.get_user_info_by_email(email)
        if user:
            return user.get("id")
        return None

    def create_user(
        self, email: str, username: str, password: str, locale: str   # pylint: disable=unused-argument
    ) -> tuple[bool, int, dict]:
        """
        Test user creation.
        :raises KeycloakGetError: user can not be created
        """
        if email != self.email_for_conflict:
            return True, 200, {}
        return False, 409, ""

    def update_user_by_id(
        self, keycloak_id: str, username: str | None = None, locale: str | None = None
    ) -> tuple[bool, int, dict]:
        """
        Test user update by keycloak id.
        """
        if keycloak_id == self.keycloak_id:
            if username:
                self.updated_username = username
            if locale:
                self.updated_locale = locale
            return True, 200, {}
        return False, 400, ""

    def delete_user_by_id(self, keycloak_id: str) -> tuple[bool, int, dict]:
        """
        Delete test user by keycloak id.
        """
        if keycloak_id == self.keycloak_id:
            self.is_deleted = True
            return True, 204, {}
        return False, 400, ""

    def send_verify_email(self, keycloak_id: str) -> bool:
        """
        Send test verification mail.
        """
        if keycloak_id == self.keycloak_id:
            return True
        return False

    def send_reset_password_email(self, keycloak_id: str) -> bool:
        """
        Send test password reset mail.
        """
        if keycloak_id == self.keycloak_id:
            self.reset_password_mail_sent = True
            return True
        return False

    def change_user_password(self, keycloak_id: str, password: str) -> bool:
        """
        Change test user password.
        """
        if keycloak_id == self.keycloak_id:
            self.updated_password = password
            return True
        return False

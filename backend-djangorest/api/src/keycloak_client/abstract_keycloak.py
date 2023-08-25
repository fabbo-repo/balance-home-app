"""
Provides a Keycloak client class.
"""
from abc import ABC, abstractmethod
from django.utils.timezone import datetime

class AbstractKeycloak(ABC):

    @abstractmethod
    def verify_access_token(self, access_token: str) -> tuple[bool, dict]:
        pass

    @abstractmethod
    def authenticate_user(self, email: str, password: str) -> dict | None:
        pass

    @abstractmethod
    def get_user_info_by_id(self, keycloak_id: str) -> dict | None:
        pass

    @abstractmethod
    def get_user_info_by_email(self, email: str) -> dict | None:
        pass

    @abstractmethod
    def get_user_sessions(self, keycloak_id: str) -> list | None:
        pass

    @abstractmethod
    def get_user_last_login(self, keycloak_id: str) -> datetime | None:
        pass

    @abstractmethod
    def get_user_id(self, email: str) -> str | None:
        pass

    @abstractmethod
    def create_user(
        self, email: str, username: str, password: str, locale: str
    ) -> tuple[bool, int, dict]:
        pass

    @abstractmethod
    def update_user_by_id(
        self, keycloak_id: str, username: str | None = None, locale: str | None = None
    ) -> tuple[bool, int, dict]:
        pass

    @abstractmethod
    def delete_user_by_id(self, keycloak_id: str) -> tuple[bool, int, dict]:
        pass

    @abstractmethod
    def send_verify_email(self, keycloak_id: str) -> bool:
        pass

    @abstractmethod
    def send_reset_password_email(self, keycloak_id: str) -> bool:
        pass

    @abstractmethod
    def change_user_password(self, keycloak_id: str, password: str) -> bool:
        pass

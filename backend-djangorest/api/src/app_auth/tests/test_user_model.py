from rest_framework.test import APITestCase
from app_auth.models import User
from django.utils.translation import gettext_lazy as _
from keycloak_client.django_client import get_keycloak_client


class UserTests(APITestCase):
    def setUp(self):
        self.keycloak_client_mock = get_keycloak_client()

        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
        }
        return super().setUp()

    def create_user(self):
        User.objects.create_user(  # pylint: disable=no-member
            **self.user_data)

    def create_super_user(self):
        User.objects.create_superuser(  # pylint: disable=no-member
            **self.user_data)

    def test_creates_user(self):
        """
        Checks if User is created as normal user
        """
        self.create_user()
        user = User.objects.get(  # pylint: disable=no-member
            keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.keycloak_id, self.user_data["keycloak_id"])
        self.assertFalse(user.is_staff)
        self.assertFalse(user.is_superuser)

    def test_creates_super_user(self):
        """
        Checks if User is created as super user
        """
        self.create_super_user()
        user = User.objects.get(  # pylint: disable=no-member
            keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.keycloak_id, self.user_data["keycloak_id"])
        self.assertEqual(user.is_staff, True)
        self.assertEqual(user.is_superuser, True)

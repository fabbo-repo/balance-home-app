import uuid
import logging
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import User, InvitationCode
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class InvitationCodeTests(APITestCase):

    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.user_post_url = reverse("user-post")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()  # pylint: disable=no-member
        # Create CurrencyType
        self.currency_type = CoinType.objects.create(  # pylint: disable=no-member
            code="EUR")
        # Test user data
        self.register_data = {
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "locale": self.keycloak_client_mock.locale,
            "inv_code": str(self.inv_code.code),
            "password": self.keycloak_client_mock.password,
            "pref_currency_type": str(self.currency_type.code)
        }
        return super().setUp()

    def user_post(self, register_data=None):
        if register_data is None:
            register_data = self.register_data
        return test_utils.post(
            self.client,
            self.user_post_url,
            data=register_data
        )

    def test_inv_code_update(self):
        """
        Checks that an invitation code gets updated after user registration
        """
        response = self.user_post()
        self.assertEqual(status.HTTP_201_CREATED, response.status_code)
        User.objects.get(keycloak_id=self.keycloak_client_mock.keycloak_id)
        # Cheks if InvitationCode gets updated
        self.assertFalse(InvitationCode.objects.get(  # pylint: disable=no-member
            code=self.inv_code.code).is_active)

    def test_user_with_inactive_inv_code(self):
        """
        Checks that an user with inactive invitation code is not created
        """
        # Create inactive InvitationCode
        inv_code2 = InvitationCode.objects.create(  # pylint: disable=no-member
            is_active=False,
            usage_left=0
        )
        # Test user data 2
        register_data2 = {
            "username": "username2",
            "email": "email2@test.com",
            "password": "password1@212",
            "inv_code": str(inv_code2.code)
        }

        response = self.user_post(register_data2)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("inv_code", [field["name"]
                      for field in response.data["fields"]])

    def test_wrong_inv_code(self):
        """
        Checks that an user with no inv_code is not created
        """
        response = self.user_post(
            {
                "username": "username2",
                "email": "email2@test.com",
                "password": "password1@212",
                "inv_cod": str(uuid.uuid4())
            }
        )
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("inv_code", [field["name"]
                      for field in response.data["fields"]])

    def test_none_inv_code(self):
        """
        Checks that an user with no inv_code is not created
        """
        response = self.user_post(
            {
                "username": self.register_data["username"],
                "email": self.register_data["email"],
                "password": self.register_data["password"]
            }
        )
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("inv_code", [field["name"]
                      for field in response.data["fields"]])

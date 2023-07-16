import logging
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from django.core.cache import cache
from coin.models import CoinType
from app_auth.models import User, InvitationCode
from app_auth.exceptions import (
    USER_EMAIL_CONFLICT_ERROR
)
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class UserPostTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        # Throttling is stored in cache
        cache.clear()

        self.user_post_url = reverse("user-post")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400)
        # Test user data
        self.user_data = {
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "pref_currency_type":
                str(CoinType.objects.create(  # pylint: disable=no-member
                    code="EUR").code)
        }
        return super().setUp()

    def test_user(self):
        """
        Checks that an user with user_post url is created
        """
        response = test_utils.post(
            self.client, self.user_post_url, self.user_data)
        self.assertEqual(status.HTTP_201_CREATED, response.status_code)
        new_user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        self.assertIsNotNone(new_user)
        self.assertEqual(new_user.keycloak_id,
                         self.keycloak_client_mock.keycloak_id)
        self.assertEqual(str(new_user.inv_code), self.user_data["inv_code"])
        self.assertEqual(str(new_user.pref_currency_type),
                         self.user_data["pref_currency_type"])

    def test_two_user_with_email(self):
        """
        Checks that an user with an used email is not created
        """
        # User 1 creation
        response = test_utils.post(
            self.client, self.user_post_url, self.user_data)
        # User 2 creation
        user_data2 = self.user_data
        user_data2["email"] = self.keycloak_client_mock.email_for_conflict
        response = test_utils.post(self.client, self.user_post_url, user_data2)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertEqual(
            USER_EMAIL_CONFLICT_ERROR,
            response.data["error_code"]
        )

    def test_empty_user(self):
        """
        Checks that an user with no data is not created
        """
        response = test_utils.post(self.client, self.user_post_url, {})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", [field["name"]
                      for field in response.data["fields"]])
        self.assertIn("username", [field["name"]
                      for field in response.data["fields"]])
        self.assertIn("password", [field["name"]
                      for field in response.data["fields"]])
        self.assertIn("inv_code", [field["name"]
                      for field in response.data["fields"]])
        self.assertIn("pref_currency_type", [field["name"]
                      for field in response.data["fields"]])
        self.assertIn("locale", [field["name"]
                      for field in response.data["fields"]])

    def test_none_email(self):
        """
        Checks that an user with no email is not created
        """
        response = test_utils.post(
            self.client,
            self.user_post_url,
            {
                "username": self.user_data["username"],
                "inv_code": self.user_data["inv_code"],
                "password": self.user_data["password"],
            }
        )
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("email", [field["name"]
                      for field in response.data["fields"]])

    def test_none_username(self):
        """
        Checks that an user with no username is not created
        """
        response = test_utils.post(
            self.client,
            self.user_post_url,
            {
                "email": self.user_data["email"],
                "inv_code": self.user_data["inv_code"],
                "password": self.user_data["password"],
            }
        )
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("username", [field["name"]
                      for field in response.data["fields"]])

    def test_short_password(self):
        """
        Checks that an user with a short password is not created
        """
        data = self.user_data
        data["password"] = "admin"
        response = test_utils.post(self.client, self.user_post_url, data)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("password", [field["name"]
                      for field in response.data["fields"]])

    def test_common_password(self):
        """
        Checks that an user with a too common password is not created
        """
        data = self.user_data
        data["password"] = "admin1234"
        response = test_utils.post(self.client, self.user_post_url, data)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("password", [field["name"]
                      for field in response.data["fields"]])

    def test_username_same_password_user_post(self):
        """
        Checks that an user with same username as password is not created
        """
        data = self.user_data
        data["username"] = "username1L24"
        data["password"] = "username1L24"
        response = test_utils.post(self.client, self.user_post_url, data)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("password", [field["name"]
                      for field in response.data["fields"]])

    def test_numeric_password_user_post(self):
        """
        Checks that an user with a numeric password is not created
        """
        data = self.user_data
        data["password"] = "12345678"
        response = test_utils.post(self.client, self.user_post_url, data)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("password", [field["name"]
                      for field in response.data["fields"]])

    def test_same_email_username(self):
        """
        Checks that an user with same email and username is not created
        """
        data = self.user_data
        data["username"] = self.user_data["email"]
        response = test_utils.post(self.client, self.user_post_url, data)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("username", [field["name"]
                      for field in response.data["fields"]])

    def test_wrong_locale(self):
        """
        Checks that an user with a wrong locale is not created
        """
        data = self.user_data
        data["locale"] = "lm"
        response = test_utils.post(self.client, self.user_post_url, data)
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertIn("locale", [field["name"]
                      for field in response.data["fields"]])

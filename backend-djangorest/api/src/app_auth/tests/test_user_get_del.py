from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import User, InvitationCode
import logging
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class UserGetDelTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.user_post_url = reverse("user-post")
        self.user_get_del_url = reverse("user-put-get-del")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )
        # User data
        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "pref_currency_type":
                str(CoinType.objects.create(  # pylint: disable=no-member
                    code="EUR").code),
        }
        # User creation
        User.objects.create(
            keycloak_id=self.user_data["keycloak_id"],
            inv_code=self.inv_code,
        )
        # Authenticate
        test_utils.authenticate_user(self.client)
        return super().setUp()

    def test_get_user_data(self):
        """
        Checks that user data is correct
        """
        response = test_utils.get(self.client, self.user_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user_data2 = {
            "username": self.user_data["username"],
            "email": self.user_data["email"],
            "expected_monthly_balance": 0,
            "expected_annual_balance": 0,
        }
        self.assertEqual(user_data2["username"], response.data["username"])
        self.assertEqual(response.data["email"], user_data2["email"])
        self.assertEqual(response.data["expected_monthly_balance"],
                         user_data2["expected_monthly_balance"])
        self.assertEqual(response.data["expected_annual_balance"],
                         user_data2["expected_annual_balance"])

    def test_delete_user(self):
        """
        Checks that user gets deleted
        """
        response = test_utils.delete(self.client, self.user_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

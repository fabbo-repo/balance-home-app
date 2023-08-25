import logging
import core.tests.utils as test_utils
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from coin.currency_converter_integration import update_exchange_data
from keycloak_client.django_client import get_keycloak_client


class CoinUrlsPermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.currency_type_list_url = reverse("currency_type_list")
        self.currency_exchange_list_url = reverse("currency_exchange_list", args=["1"])
        self.currency_exchange_code_url = reverse(
            "currency_exchange_code", args=["EUR"]
        )

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )
        # Create CoinType
        self.currency_type = CoinType.objects.create(  # pylint: disable=no-member
            code="EUR"
        )
        # Test user data
        self.user_data1 = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "pref_currency_type": str(self.currency_type.code),
        }
        self.user_data2 = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id + "1",
            "username": "username2",
            "email": "email2@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
            "locale": "en",
            "pref_currency_type": str(self.currency_type.code),
        }
        # User creation
        User.objects.create(
            keycloak_id=self.user_data1["keycloak_id"],
            inv_code=self.inv_code,
        )
        User.objects.create(
            keycloak_id=self.user_data2["keycloak_id"],
            inv_code=self.inv_code,
        )
        return super().setUp()

    def test_currency_type_get_url(self):
        """
        Checks permissions with Coin Type get
        """
        # Try with an specific coin
        response = test_utils.get(
            self.client,
            self.currency_type_list_url + "/" + str(self.currency_type.code),
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with an specific coin with authentication
        test_utils.authenticate_user(self.client)
        response = test_utils.get(
            self.client,
            self.currency_type_list_url + "/" + str(self.currency_type.code),
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_currency_type_list_url(self):
        """
        Checks permissions with Coin Type list
        """
        # List coin type data without authentication
        response = test_utils.get(self.client, self.currency_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # List coin type data with authentication
        test_utils.authenticate_user(self.client)
        response = test_utils.get(self.client, self.currency_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_currency_exchange_list_url(self):
        """
        Checks permissions with Coin Exchange list
        """
        # List coin exchange list without authentication
        response = test_utils.get(self.client, self.currency_exchange_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # List coin exchange list with authentication
        test_utils.authenticate_user(self.client)
        response = test_utils.get(self.client, self.currency_exchange_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_currency_exchange_code_url(self):
        """
        Checks permissions with Coin Exchange code
        """
        update_exchange_data()
        # List coin exchange list without authentication
        response = test_utils.get(self.client, self.currency_exchange_code_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # List coin exchange list with authentication
        test_utils.authenticate_user(self.client)
        response = test_utils.get(self.client, self.currency_exchange_code_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

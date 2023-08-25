import logging
import core.tests.utils as test_utils
from django.utils.timezone import now
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from revenue.models import Revenue, RevenueType
from keycloak_client.django_client import get_keycloak_client


class RevenueLogicTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.revenue_url = reverse("revenue-list")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )
        # Create CurrencyType
        self.currency_type = CoinType.objects.create(code="EUR")
        # User data
        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "pref_currency_type": str(self.currency_type.code),
        }
        # User creation
        self.user = User.objects.create(
            keycloak_id=self.user_data["keycloak_id"],
            pref_currency_type=self.currency_type,
            balance=1,
            inv_code=self.inv_code,
        )

        self.rev_type = RevenueType.objects.create(name="test")

    def get_revenue_data(self):
        return {
            "name": "Test name",
            "description": "",
            "real_quantity": 2.0,
            "currency_type": self.currency_type.code,
            "rev_type": self.rev_type.name,
            "date": str(now().date()),
            "owner": str(self.user),
        }

    def authenticate_add_revenue(self):
        test_utils.authenticate_user(self.client)
        data = self.get_revenue_data()
        # Add new revenue
        test_utils.post(self.client, self.revenue_url, data)

    def test_revenue_post(self):
        """
        Checks balance gets updated with Revenue post
        """
        data = self.get_revenue_data()
        test_utils.authenticate_user(self.client)
        test_utils.post(self.client, self.revenue_url, data)
        user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.balance, 3)
        # Negative quantity not allowed
        data["real_quantity"] = -10.0
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn(
            "real_quantity", [field["name"] for field in response.data["fields"]]
        )

    def test_revenue_patch(self):
        """
        Checks balance gets updated with Revenue patch (similar to put)
        """
        data = self.get_revenue_data()
        test_utils.authenticate_user(self.client)
        test_utils.post(self.client, self.revenue_url, data)
        revenue = Revenue.objects.get(name="Test name")
        # Patch method
        test_utils.patch(
            self.client,
            self.revenue_url + "/" + str(revenue.id),
            {"real_quantity": 35.0},
        )
        user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.balance, 36)

    def test_revenue_delete_url(self):
        """
        Checks balance gets updated with Revenue delete
        """
        data = self.get_revenue_data()
        test_utils.authenticate_user(self.client)
        test_utils.post(self.client, self.revenue_url, data)
        data2 = data
        data2["name"] = "test"
        test_utils.post(self.client, self.revenue_url, data2)
        revenue = Revenue.objects.get(name="Test name")
        # Delete method
        test_utils.delete(self.client, self.revenue_url + "/" + str(revenue.id))
        user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.balance, 3)

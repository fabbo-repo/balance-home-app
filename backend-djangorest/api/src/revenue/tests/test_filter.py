import logging
import core.tests.utils as test_utils
from django.utils.timezone import now, timedelta
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from revenue.models import RevenueType
from keycloak_client.django_client import get_keycloak_client


class RevenueFilterTests(APITestCase):
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
            inv_code=self.inv_code,
        )
        self.rev_type = RevenueType.objects.create(name="test")
        return super().setUp()

    def get_revenue_data(self):
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.6,
            "currency_type": self.currency_type.code,
            "rev_type": self.rev_type.name,
            "date": str(now().date()),
            "owner": str(self.user.keycloak_id),
        }

    def authenticate_add_revenue(self):
        test_utils.authenticate_user(self.client)
        data = self.get_revenue_data()
        # Add new revenue
        test_utils.post(self.client, self.revenue_url, data)

    def test_revenue_filter_date(self):
        """
        Checks Revenue filter by date
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url + "?date=" + str(now().date())
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_revenue_filter_date_from_to(self):
        """
        Checks Revenue filter by date form to
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = (
            self.revenue_url
            + "?date_from="
            + str(now().date() - timedelta(days=1))
            + "&date_to="
            + str(now().date() + timedelta(days=1))
        )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_revenue_filter_rev_type(self):
        """
        Checks Revenue filter by rev_type
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url + "?rev_type=test"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_revenue_filter_currency_type(self):
        """
        Checks Revenue filter by currency_type
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url + "?currency_type=EUR"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_revenue_filter_quantity_min_and_max(self):
        """
        Checks Revenue filter by quantity min and max
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = (
            self.revenue_url + "?converted_quantity_min=1.0&converted_quantity_max=3.0"
        )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)
        # Get revenue data
        url = (
            self.revenue_url + "?converted_quantity_min=6.0&converted_quantity_max=8.0"
        )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 0)

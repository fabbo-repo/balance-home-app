import logging
import core.tests.utils as test_utils
from django.utils.timezone import now, timedelta
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from expense.models import ExpenseType
from keycloak_client.django_client import get_keycloak_client


class ExpenseFilterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.expense_url = reverse("expense-list")

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
        self.exp_type = ExpenseType.objects.create(name="test")
        return super().setUp()

    def get_expense_data(self):
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.5,
            "currency_type": self.currency_type.code,
            "exp_type": self.exp_type.name,
            "date": str(now().date()),
            "owner": str(self.user.keycloak_id),
        }

    def authenticate_add_expense(self):
        test_utils.authenticate_user(self.client)
        data = self.get_expense_data()
        # Add new expense
        test_utils.post(self.client, self.expense_url, data)

    def test_expense_filter_date(self):
        """
        Checks Expense filter by date
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url + "?date=" + str(now().date())
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_expense_filter_date_from_to(self):
        """
        Checks Expense filter by date form to
        """
        self.authenticate_add_expense()
        # Get expense data
        url = (
            self.expense_url
            + "?date_from="
            + str(now().date() - timedelta(days=1))
            + "&date_to="
            + str(now().date() + timedelta(days=1))
        )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_expense_filter_exp_type(self):
        """
        Checks Expense filter by exp_type
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url + "?exp_type=test"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_expense_filter_currency_type(self):
        """
        Checks Expense filter by currency_type
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url + "?currency_type=EUR"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_expense_filter_quantity_min_and_max(self):
        """
        Checks Expense filter by quantity min and max
        """
        self.authenticate_add_expense()
        # Get expense data
        url = (
            self.expense_url + "?converted_quantity_min=1.0&converted_quantity_max=3.0"
        )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)
        # Get expense data
        url = (
            self.expense_url + "?converted_quantity_min=6.0&converted_quantity_max=8.0"
        )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 0)

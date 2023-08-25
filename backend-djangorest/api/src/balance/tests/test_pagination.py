from django.utils.timezone import now
from rest_framework.test import APITestCase
from django.urls import reverse
from balance.models import AnnualBalance, CoinType, MonthlyBalance
from app_auth.models import InvitationCode, User
import logging
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class BalancePaginationTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.annual_balance_list = reverse("annual-balance-list")
        self.monthly_balance_list = reverse("monthly-balance-list")

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
            inv_code=self.inv_code,
        )
        return super().setUp()

    def get_annual_balance_data(self):
        return {
            "gross_quantity": 1.1,
            "expected_quantity": 2.2,
            "currency_type": self.currency_type,
            "owner": self.user,
            "year": now().date().year,
        }

    def get_monthly_balance_data(self):
        return {
            "gross_quantity": 1.1,
            "expected_quantity": 2.2,
            "currency_type": self.currency_type,
            "owner": self.user,
            "year": now().date().year,
            "month": now().date().month,
        }

    def authenticate_add_annual_balance(self):
        test_utils.authenticate_user(self.client)
        self.add_annual_balance()

    def add_annual_balance(self):
        data = self.get_annual_balance_data()
        AnnualBalance.objects.create(
            gross_quantity=data["gross_quantity"],
            expected_quantity=data["expected_quantity"],
            currency_type=data["currency_type"],
            owner=data["owner"],
            year=data["year"],
        )

    def authenticate_add_monthly_balance(self):
        test_utils.authenticate_user(self.client)
        self.add_monthly_balance()

    def add_monthly_balance(self):
        data = self.get_monthly_balance_data()
        MonthlyBalance.objects.create(
            gross_quantity=data["gross_quantity"],
            expected_quantity=data["expected_quantity"],
            currency_type=data["currency_type"],
            owner=data["owner"],
            year=data["year"],
            month=data["month"],
        )

    def test_annual_balance_pagination_scheme(self):
        """
        Checks AnnualBalance pagination scheme is correct
        """
        # Add new AnnualBalance
        self.authenticate_add_annual_balance()
        # Get AnnualBalance data
        response = test_utils.get(self.client, self.annual_balance_list)
        scheme = dict(response.data)
        scheme["results"] = []
        results = dict(response.data)["results"]

        for result in results:
            result.pop("created")
            scheme["results"] += [dict(result)]
        expected_scheme = {
            "count": 1,
            "next": None,
            "previous": None,
            "results": [
                {
                    "gross_quantity": 1.1,
                    "expected_quantity": 2.2,
                    "currency_type": "EUR",
                    "year": now().date().year,
                }
            ],
        }
        self.assertEqual(scheme, expected_scheme)

    def test_annual_balance_two_pages(self):
        """
        Checks 2 pages of AnnualBalance data is correct
        """
        # Add First AnnualBalance
        self.authenticate_add_annual_balance()
        for i in range(19):
            self.add_annual_balance()
        # Get First page AnnualBalance data
        response = test_utils.get(self.client, self.annual_balance_list)
        data = dict(response.data)
        self.assertEqual(data["count"], 20)
        # 10 AnnualBalance in the first page
        self.assertEqual(len(data["results"]), 10)
        # Second page
        response = test_utils.get(self.client, data["next"])
        self.assertEqual(data["count"], 20)
        # 10 AnnualBalance in the first page
        self.assertEqual(len(data["results"]), 10)

    def test_monthly_balance_pagination_scheme(self):
        """
        Checks MonthlyBalance pagination scheme is correct
        """
        # Add new MonthlyBalance
        self.authenticate_add_monthly_balance()
        # Get MonthlyBalance data
        response = test_utils.get(self.client, self.monthly_balance_list)
        scheme = dict(response.data)
        scheme["results"] = []
        results = dict(response.data)["results"]

        for result in results:
            result.pop("created")
            scheme["results"] += [dict(result)]
        expected_scheme = {
            "count": 1,
            "next": None,
            "previous": None,
            "results": [
                {
                    "gross_quantity": 1.1,
                    "expected_quantity": 2.2,
                    "currency_type": "EUR",
                    "year": now().date().year,
                    "month": now().date().month,
                }
            ],
        }
        self.assertEqual(scheme, expected_scheme)

    def test_monthly_balance_two_pages(self):
        """
        Checks 2 pages of MonthlyBalance data is correct
        """
        # Add First MonthlyBalance
        self.authenticate_add_monthly_balance()
        for i in range(19):
            self.add_monthly_balance()
        # Get First page MonthlyBalance data
        response = test_utils.get(self.client, self.monthly_balance_list)
        data = dict(response.data)
        self.assertEqual(data["count"], 20)
        # 10 MonthlyBalance in the first page
        self.assertEqual(len(data["results"]), 10)
        # Second page
        response = test_utils.get(self.client, data["next"])
        self.assertEqual(data["count"], 20)
        # 10 MonthlyBalance in the first page
        self.assertEqual(len(data["results"]), 10)

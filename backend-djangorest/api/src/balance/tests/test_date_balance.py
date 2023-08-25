from rest_framework import status
from rest_framework.test import APITestCase
import logging
from django.urls import reverse
from balance.models import AnnualBalance, MonthlyBalance
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from expense.models import Expense, ExpenseType
from revenue.models import Revenue, RevenueType
from django.utils.timezone import now, timedelta
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class DateBalanceTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.expense_url = reverse("expense-list")
        self.revenue_url = reverse("revenue-list")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.currency_type = CoinType.objects.create(code="EUR")
        # User data
        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "pref_currency_type": str(self.currency_type.code),
            "expected_annual_balance": 10.0,
            "expected_monthly_balance": 10.0,
        }
        # User creation
        user = User.objects.create(
            keycloak_id=self.user_data["keycloak_id"],
            pref_currency_type=self.currency_type,
            expected_annual_balance=self.user_data["expected_annual_balance"],
            expected_monthly_balance=self.user_data["expected_monthly_balance"],
            inv_code=self.inv_code,
        )
        return super().setUp()

    def get_expense_data(self):
        exp_type = ExpenseType.objects.create(name="test")
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "currency_type": self.currency_type.code,
            "exp_type": exp_type.name,
            "date": str(now().date()),
        }

    def get_revenue_data(self):
        rev_type = RevenueType.objects.create(name="test")
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "currency_type": self.currency_type.code,
            "rev_type": rev_type.name,
            "date": str(now().date()),
        }

    def test_revenue_post_date_balances(self):
        """
        Checks that posting a revenue creates a monthly and annual balance
        with the revenue quantity
        """
        # Authenticate user
        test_utils.authenticate_user(self.client)
        data = self.get_revenue_data()
        # Post revenue
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        last_monthly_balance = MonthlyBalance.objects.last()
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(data["real_quantity"], last_monthly_balance.gross_quantity)
        self.assertEqual(10.0, last_monthly_balance.expected_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(data["real_quantity"], last_annual_balance.gross_quantity)
        self.assertEqual(10.0, last_annual_balance.expected_quantity)

    def test_expense_post_date_balances(self):
        """
        Checks that posting a expense creates a monthly and annual balance
        with the expense quantity
        """
        # Authenticate user
        test_utils.authenticate_user(self.client)
        data = self.get_expense_data()
        # Post expense
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        last_monthly_balance = MonthlyBalance.objects.last()
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(-data["real_quantity"], last_monthly_balance.gross_quantity)
        self.assertEqual(10.0, last_monthly_balance.expected_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(-data["real_quantity"], last_annual_balance.gross_quantity)
        self.assertEqual(10.0, last_annual_balance.expected_quantity)

    def test_revenue_delete_date_balances(self):
        """
        Checks that deleting a revenue creates a monthly and annual balance
        with the revenue quantity
        """
        # Authenticate user
        test_utils.authenticate_user(self.client)
        data = self.get_revenue_data()
        # Post revenue
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Delete revenue
        rev = Revenue.objects.get(name=data["name"])
        response = test_utils.delete(self.client, self.revenue_url + "/" + str(rev.id))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        last_monthly_balance = MonthlyBalance.objects.last()
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(0, last_monthly_balance.gross_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(0, last_annual_balance.gross_quantity)

    def test_expense_delete_date_balances(self):
        """
        Checks that deleting a expense creates a monthly and annual balance
        with the expense quantity
        """
        # Authenticate user
        test_utils.authenticate_user(self.client)
        data = self.get_expense_data()
        # Post expense
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Delete expense
        exp = Expense.objects.get(name=data["name"])
        response = test_utils.delete(self.client, self.expense_url + "/" + str(exp.id))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        last_monthly_balance = MonthlyBalance.objects.last()
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(0, last_monthly_balance.gross_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(0, last_annual_balance.gross_quantity)

    def test_revenue_update_date_balances(self):
        """
        Checks that updating a revenue creates a monthly and annual balance
        with the revenue quantity
        """
        # Authenticate user
        test_utils.authenticate_user(self.client)
        data = self.get_revenue_data()
        # Post revenue
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Update revenue dfiferent date
        rev = Revenue.objects.get(name=data["name"])
        past_date = (now() - timedelta(days=32)).date()
        response = test_utils.patch(
            self.client, self.revenue_url + "/" + str(rev.id), {"date": str(past_date)}
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        last_monthly_balance = MonthlyBalance.objects.last()
        second_to_last_monthly_balance = MonthlyBalance.objects.get(
            month=past_date.month
        )
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(0, last_monthly_balance.gross_quantity)
        self.assertEqual(past_date.year, second_to_last_monthly_balance.year)
        self.assertEqual(past_date.month, second_to_last_monthly_balance.month)
        self.assertEqual(
            data["real_quantity"], second_to_last_monthly_balance.gross_quantity
        )
        last_annual_balance = AnnualBalance.objects.get(year=past_date.year)
        self.assertEqual(past_date.year, last_annual_balance.year)
        self.assertEqual(data["real_quantity"], last_annual_balance.gross_quantity)
        # Test update diferent quantity and date
        response = test_utils.patch(
            self.client,
            self.revenue_url + "/" + str(rev.id),
            {"date": str(now().date()), "real_quantity": 10.14},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        last_monthly_balance = MonthlyBalance.objects.last()
        second_to_last_monthly_balance = MonthlyBalance.objects.get(
            month=past_date.month
        )
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(10.14, last_monthly_balance.gross_quantity)
        self.assertEqual(past_date.year, second_to_last_monthly_balance.year)
        self.assertEqual(past_date.month, second_to_last_monthly_balance.month)
        self.assertEqual(0, second_to_last_monthly_balance.gross_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(10.14, last_annual_balance.gross_quantity)
        # Test update diferent quantity
        response = test_utils.patch(
            self.client, self.revenue_url + "/" + str(rev.id), {"real_quantity": 20.86}
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        last_monthly_balance = MonthlyBalance.objects.last()
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(20.86, last_monthly_balance.gross_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(20.86, last_annual_balance.gross_quantity)

    def test_expense_update_date_balances(self):
        """
        Checks that updating a expense creates a monthly and annual balance
        with the expense quantity
        """
        # Authenticate user
        test_utils.authenticate_user(self.client)
        data = self.get_expense_data()
        # Post expense
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Update expense dfiferent date
        exp = Expense.objects.get(name=data["name"])
        past_date = (now() - timedelta(days=32)).date()
        response = test_utils.patch(
            self.client, self.expense_url + "/" + str(exp.id), {"date": str(past_date)}
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        last_monthly_balance = MonthlyBalance.objects.last()
        second_to_last_monthly_balance = MonthlyBalance.objects.get(
            month=past_date.month
        )
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(0, last_monthly_balance.gross_quantity)
        self.assertEqual(past_date.year, second_to_last_monthly_balance.year)
        self.assertEqual(past_date.month, second_to_last_monthly_balance.month)
        self.assertEqual(
            -data["real_quantity"], second_to_last_monthly_balance.gross_quantity
        )
        last_annual_balance = AnnualBalance.objects.get(year=past_date.year)
        self.assertEqual(past_date.year, last_annual_balance.year)
        self.assertEqual(-data["real_quantity"], last_annual_balance.gross_quantity)
        # Test update diferent quantity and date
        response = test_utils.patch(
            self.client,
            self.expense_url + "/" + str(exp.id),
            {"date": str(now().date()), "real_quantity": 10.14},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        last_monthly_balance = MonthlyBalance.objects.last()
        second_to_last_monthly_balance = MonthlyBalance.objects.get(
            month=past_date.month
        )
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(-10.14, last_monthly_balance.gross_quantity)
        self.assertEqual(past_date.year, second_to_last_monthly_balance.year)
        self.assertEqual(past_date.month, second_to_last_monthly_balance.month)
        self.assertEqual(0, second_to_last_monthly_balance.gross_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(-10.14, last_annual_balance.gross_quantity)
        # Test update diferent quantity
        response = test_utils.patch(
            self.client, self.expense_url + "/" + str(exp.id), {"real_quantity": 20.86}
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        last_monthly_balance = MonthlyBalance.objects.last()
        self.assertEqual(now().date().year, last_monthly_balance.year)
        self.assertEqual(now().date().month, last_monthly_balance.month)
        self.assertEqual(-20.86, last_monthly_balance.gross_quantity)
        last_annual_balance = AnnualBalance.objects.last()
        self.assertEqual(now().date().year, last_annual_balance.year)
        self.assertEqual(-20.86, last_annual_balance.gross_quantity)

import logging
import core.tests.utils as test_utils
from rest_framework.test import APITestCase
from rest_framework import status
from django.utils.timezone import now
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from expense.models import Expense, ExpenseType
from keycloak_client.django_client import get_keycloak_client


class ExpenseLogicTests(APITestCase):
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
            balance=10,
            inv_code=self.inv_code,
        )

        self.exp_type = ExpenseType.objects.create(name="test")

    def get_expense_data(self):
        return {
            "name": "Test name",
            "description": "",
            "real_quantity": 2.0,
            "currency_type": self.currency_type.code,
            "exp_type": self.exp_type.name,
            "date": str(now().date()),
            "owner": str(self.user),
        }

    def authenticate_add_expense(self):
        test_utils.authenticate_user(self.client)
        data = self.get_expense_data()
        # Add new expense
        test_utils.post(self.client, self.expense_url, data)

    def test_expense_post(self):
        """
        Checks balance gets updated with Expense post
        """
        data = self.get_expense_data()
        test_utils.authenticate_user(self.client)
        test_utils.post(self.client, self.expense_url, data)
        user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.balance, 8)
        # Negative quantity not allowed
        data["real_quantity"] = -10.0
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn(
            "real_quantity", [field["name"] for field in response.data["fields"]]
        )

    def test_expense_patch(self):
        """
        Checks balance gets updated with Expense patch (similar to put)
        """
        data = self.get_expense_data()
        test_utils.authenticate_user(self.client)
        test_utils.post(self.client, self.expense_url, data)
        expense = Expense.objects.get(name="Test name")
        # Patch method
        test_utils.patch(
            self.client,
            self.expense_url + "/" + str(expense.id),
            {"real_quantity": 5.0},
        )
        user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.balance, 5)

    def test_expense_delete_url(self):
        """
        Checks balance gets updated with Expense delete
        """
        # Add first expense
        data = self.get_expense_data()
        test_utils.authenticate_user(self.client)
        test_utils.post(self.client, self.expense_url, data)
        data2 = data
        data2["name"] = "test"
        # Add second expense
        test_utils.post(self.client, self.expense_url, data2)
        expense = Expense.objects.get(name="Test name")
        # Delete second expense
        test_utils.delete(self.client, self.expense_url + "/" + str(expense.id))
        user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(user.balance, 8)

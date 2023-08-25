from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from rest_framework.test import APITestCase
from coin.models import CoinType
from expense.models import Expense, ExpenseType
from app_auth.models import InvitationCode, User
from keycloak_client.django_client import get_keycloak_client


class ExpenseModelTests(APITestCase):
    def setUp(self):
        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        # Create CoinType
        self.currency_type = CoinType.objects.create(code="EUR")
        # Test user data
        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": "username1",
            "email": "email1@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
            "pref_currency_type": str(self.currency_type.code),
        }
        self.exp_type = ExpenseType.objects.create(name="test")
        return super().setUp()

    def get_expense_data(self):
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "currency_type": self.currency_type,
            "exp_type": self.exp_type,
            "date": now().date(),
            "owner": self.create_user(),
        }

    def create_user(self):
        return User.objects.create(
            keycloak_id=self.user_data["keycloak_id"],
            inv_code=self.inv_code,
            pref_currency_type=self.currency_type,
        )

    def test_creates_exp_type(self):
        """
        Checks if exp_type is created
        """
        exp_type = ExpenseType.objects.create(name="test2")
        self.assertEqual(exp_type.name, "test2")

    def test_creates_expense(self):
        """
        Checks if expense is created
        """
        data = self.get_expense_data()
        data["converted_quantity"] = 2.0
        expense = Expense.objects.create(**data)
        self.assertEqual(expense.name, data["name"])
        self.assertEqual(expense.description, data["description"])
        self.assertEqual(expense.real_quantity, data["real_quantity"])
        self.assertEqual(expense.converted_quantity, data["converted_quantity"])
        self.assertEqual(expense.currency_type, data["currency_type"])
        self.assertEqual(expense.exp_type, data["exp_type"])
        self.assertEqual(expense.date, data["date"])
        self.assertEqual(expense.owner, data["owner"])

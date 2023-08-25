from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CurrencyExchange, CoinType
from app_auth.models import User, InvitationCode
import logging
from expense.models import Expense, ExpenseType
from coin.currency_converter_integration import (
    NoCoinExchangeException,
    OldExchangeException,
    UnsupportedExchangeException,
    _convert,
    update_exchange_data,
)
from revenue.models import Revenue, RevenueType
from django.utils.timezone import now, timedelta
import core.tests.utils as test_utils
import json
from unittest import mock
from django.conf import settings
from keycloak_client.django_client import get_keycloak_client


class CoinLogicExchangesTests(APITestCase):
    def setUp(self):
        # Mock Celery tasks
        settings.CELERY_TASK_ALWAYS_EAGER = True
        mock.patch("coin.tasks.update_exchange_data", return_value=None)

        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.revenue_url = reverse("revenue-list")
        self.expense_url = reverse("expense-list")
        self.user_put_get_del_url = reverse("user-put-get-del")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )
        # Create CoinTypes
        self.currency_type1 = CoinType.objects.create(  # pylint: disable=no-member
            code="EUR"
        )
        self.currency_type2 = CoinType.objects.create(  # pylint: disable=no-member
            code="USD"
        )
        self.currency_type3 = CoinType.objects.create(  # pylint: disable=no-member
            code="CAD"
        )
        # Test user data
        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "balance": 10.0,
            "pref_currency_type": str(self.currency_type1.code),
        }
        # User creation
        User.objects.create(
            keycloak_id=self.user_data["keycloak_id"],
            inv_code=self.inv_code,
            balance=self.user_data["balance"],
            pref_currency_type=self.currency_type1,
        )
        # Authenticate user
        test_utils.authenticate_user(self.client)
        return super().setUp()

    def get_create_revenue_type_data(self, name="test"):
        rev_type, created = RevenueType.objects.get_or_create(name=name)
        return rev_type

    def get_revenue_data(self, currency_type):
        rev_type = self.get_create_revenue_type_data()
        owner = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 1.0,
            "currency_type": currency_type.code,
            "rev_type": rev_type.name,
            "date": str(now().date()),
            "owner": owner,
            "owner": str(owner.id),
        }

    def get_create_revenue(self, currency_type):
        rev_type = self.get_create_revenue_type_data()
        owner = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        return Revenue.objects.create(
            name="Test name",
            description="Test description",
            real_quantity=1.0,
            currency_type=currency_type,
            rev_type=rev_type,
            date=now(),
            owner=owner,
        )

    def get_create_expense_type_data(self, name="test"):
        exp_type, created = ExpenseType.objects.get_or_create(name=name)
        return exp_type

    def get_expense_data(self, currency_type):
        exp_type = self.get_create_expense_type_data()
        owner = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 1.0,
            "currency_type": currency_type.code,
            "exp_type": exp_type.name,
            "date": str(now().date()),
            "owner": str(owner.id),
        }

    def get_create_expense(self, currency_type):
        exp_type = self.get_create_expense_type_data()
        owner = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        return Expense.objects.create(
            name="Test name",
            description="Test description",
            real_quantity=1.0,
            converted_quantity=1.0,
            currency_type=currency_type,
            exp_type=exp_type,
            date=now(),
            owner=owner,
        )

    def test_currency_converter_service(self):
        """
        Checks if currency converter service works
        """
        try:
            update_exchange_data()
            CurrencyExchange.objects.get(created__date=now().date())
            self.assertTrue(True)
        except:
            self.assertTrue(False)

    def test_currency_converter_service_no_coin_exception(self):
        """
        Checks if currency converter service raise `NoCoinExchangeException`
        """
        self.assertRaises(
            NoCoinExchangeException,
            _convert,
            self.currency_type1,
            self.currency_type2,
            2,
        )

    def test_currency_converter_service_old_exception(self):
        """
        Checks if currency converter service raise `OldExchangeException`
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        currency_exchange = CurrencyExchange.objects.create(
            exchange_data=json.dumps(exchange)
        )
        currency_exchange.created = now() - timedelta(days=2)
        currency_exchange.save()
        self.assertRaises(
            OldExchangeException, _convert, self.currency_type1, self.currency_type2, 2
        )

    def test_currency_converter_service_old_exception(self):
        """
        Checks if currency converter service raise `OldExchangeException`
        """
        exchange = {}
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        self.assertRaises(
            UnsupportedExchangeException,
            _convert,
            self.currency_type1,
            self.currency_type2,
            2,
        )

    def test_post_revenue_diff_currency_type(self):
        """
        Check `posting` an revenue with coin type different
        from the user"s prefered coin type results in a conversion
        of the revenue quantity
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        rev_data = self.get_revenue_data(self.currency_type2)
        resp = test_utils.post(self.client, self.revenue_url, rev_data)
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            User.objects.get(keycloak_id=self.user_data["keycloak_id"]).balance,
            self.user_data["balance"] + (rev_data["real_quantity"] * 1.3),
        )

    def test_post_expense_diff_currency_type(self):
        """
        Check `posting` an expense with coin type different
        from the user"s prefered coin type results in a conversion
        of the expense quantity
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        exp_data = self.get_expense_data(self.currency_type2)
        resp = test_utils.post(self.client, self.expense_url, exp_data)
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            User.objects.get(keycloak_id=self.user_data["keycloak_id"]).balance,
            self.user_data["balance"] - (exp_data["real_quantity"] * 1.3),
        )

    def test_patch_revenue_diff_currency_type(self):
        """
        Check `patching` an revenue with coin type different
        from the user"s prefered coin type to a another different
        `currency_type` results in an extra conversion of the revenue
        quantity
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        prev_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        rev = self.get_create_revenue(self.currency_type2)
        new_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        self.assertEqual(
            new_balance, round(prev_balance + (rev.real_quantity * 1.3), 2)
        )
        prev_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        resp = test_utils.patch(
            self.client,
            self.revenue_url + "/" + str(rev.id),
            {"real_quantity": 2, "currency_type": self.currency_type3.code},
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        new_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        self.assertEqual(
            new_balance, round(prev_balance + (2 * 0.8) - (rev.real_quantity * 1.3), 2)
        )

    def test_patch_expense_diff_currency_type(self):
        """
        Check `patching` an expense with coin type different
        from the user"s prefered coin type to a another different
        `currency_type` results in an extra conversion of the expense
        quantity
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        exp = self.get_create_expense(self.currency_type2)
        prev_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        resp = test_utils.patch(
            self.client,
            self.expense_url + "/" + str(exp.id),
            {"real_quantity": 2, "currency_type": self.currency_type3.code},
        )
        new_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(
            new_balance,
            round(prev_balance - ((2 * 0.8) - (exp.real_quantity * 1.3)), 2),
        )

    def test_delete_revenue_diff_currency_type(self):
        """
        Check `deleting` an revenue with coin type different
        from the user"s prefered `currency_type` results in a
        conversion of the revenue quantity
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        rev = self.get_create_revenue(self.currency_type2)
        prev_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        resp = test_utils.delete(self.client, self.revenue_url + "/" + str(rev.id))
        new_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(
            new_balance, round(prev_balance - (rev.real_quantity * 1.3), 2)
        )

    def test_delete_expense_diff_currency_type(self):
        """
        Check `deleting` an expense with coin type different
        from the user"s prefered `currency_type` results in a
        conversion of the expense quantity
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        exp = self.get_create_expense(self.currency_type2)
        prev_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        resp = test_utils.delete(self.client, self.expense_url + "/" + str(exp.id))
        new_balance = User.objects.get(
            keycloak_id=self.user_data["keycloak_id"]
        ).balance
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(
            new_balance, round(prev_balance + (exp.real_quantity * 1.3), 2)
        )

    def test_user_pref_currency_type(self):
        """
        Check changing user"s `pref_currency_type` should convert
        user"s balance
        """
        exchange = {
            "EUR": {"USD": 0.8, "CAD": 1.2},
            "USD": {"CAD": 1.5, "EUR": 1.3},
            "CAD": {"USD": 0.6, "EUR": 0.8},
        }
        CurrencyExchange.objects.create(exchange_data=json.dumps(exchange))
        resp = test_utils.patch(
            self.client,
            self.user_put_get_del_url,
            {
                "balance": self.user_data["balance"],
                "pref_currency_type": self.currency_type2.code,
            },
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        updated_user = User.objects.get(keycloak_id=self.user_data["keycloak_id"])
        self.assertEqual(updated_user.pref_currency_type, self.currency_type2)
        self.assertEqual(
            updated_user.balance, round(self.user_data["balance"] * 0.8, 2)
        )

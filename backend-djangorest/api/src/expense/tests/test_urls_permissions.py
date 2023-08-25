import logging
import core.tests.utils as test_utils
from django.utils.timezone import now
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from expense.models import Expense, ExpenseType
from keycloak_client.django_client import get_keycloak_client


class ExpenseUrlsPermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.expense_url = reverse("expense-list")
        self.exp_type_list_url = reverse("expense-type-list")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )
        # Create CoinTypes
        currency_type1 = CoinType.objects.create(  # pylint: disable=no-member
            code="EUR"
        )
        currency_type2 = CoinType.objects.create(  # pylint: disable=no-member
            code="USD"
        )
        # Test user data
        self.user_data1 = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "pref_currency_type": str(currency_type1.code),
        }
        self.user_data2 = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id + "1",
            "username": "username2",
            "email": "email2@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
            "locale": "en",
            "pref_currency_type": str(currency_type2.code),
        }
        # User creation
        User.objects.create(
            keycloak_id=self.user_data1["keycloak_id"],
            pref_currency_type=currency_type1,
            inv_code=self.inv_code,
        )
        User.objects.create(
            keycloak_id=self.user_data2["keycloak_id"],
            pref_currency_type=currency_type2,
            inv_code=self.inv_code,
        )
        return super().setUp()

    def get_expense_type_data(self):
        exp_type = ExpenseType.objects.create(name="test")
        return {"name": exp_type.name, "image": exp_type.image}

    def get_expense_data(self):
        exp_type = ExpenseType.objects.create(name="test")
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "currency_type": self.user_data1["pref_currency_type"],
            "exp_type": exp_type.name,
            "date": str(now().date()),
        }

    def test_expense_type_get_list_url(self):
        """
        Checks permissions with Expense Type get and list
        """
        data = self.get_expense_type_data()
        # Get expense type data without authentication
        response = test_utils.get(self.client, self.exp_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with an specific expense
        response = test_utils.get(
            self.client, self.exp_type_list_url + "/" + str(data["name"])
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get expense type data with authentication
        test_utils.authenticate_user(self.client)
        response = test_utils.get(self.client, self.exp_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Try with an specific expense
        response = test_utils.get(
            self.client, self.exp_type_list_url + "/" + str(data["name"])
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_expense_post_url(self):
        """
        Checks permissions with Expense post
        """
        data = self.get_expense_data()
        # Try without authentication
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with authentication
        test_utils.authenticate_user(self.client)
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Compare owner
        expense = Expense.objects.get(name="Test name")
        self.assertEqual(expense.owner.keycloak_id, self.user_data1["keycloak_id"])

    def test_expense_get_list_url(self):
        """
        Checks permissions with Expense get and list
        """
        data = self.get_expense_data()
        # Add new expense as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        test_utils.post(self.client, self.expense_url, data)
        # Get expense data as user1
        response = test_utils.get(self.client, self.expense_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 1)
        # Get expense data as user2
        test_utils.authenticate_user(self.client, self.user_data2["keycloak_id"])
        response = test_utils.get(self.client, self.expense_url)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 0)
        # Try with an specific expense
        expense = Expense.objects.get(name="Test name")
        response = test_utils.get(self.client, self.expense_url + "/" + str(expense.id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_expense_put_url(self):
        """
        Checks permissions with Expense patch (almost same as put)
        """
        data = self.get_expense_data()
        # Add new expense as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        test_utils.post(self.client, self.expense_url, data)
        expense = Expense.objects.get(name="Test name")
        # Try update as user1
        response = test_utils.patch(
            self.client,
            self.expense_url + "/" + str(expense.id),
            {"real_quantity": 35.0},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check expense
        expense = Expense.objects.get(name="Test name")
        self.assertEqual(expense.real_quantity, 35.0)
        # Try update as user2
        test_utils.authenticate_user(self.client, self.user_data2["keycloak_id"])
        response = test_utils.patch(
            self.client,
            self.expense_url + "/" + str(expense.id),
            {"real_quantity": 30.0},
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_expense_delete_url(self):
        """
        Checks permissions with Expense delete
        """
        data = self.get_expense_data()
        # Add new expense as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        test_utils.post(self.client, self.expense_url, data)
        # Delete expense data as user2
        test_utils.authenticate_user(self.client, self.user_data2["keycloak_id"])
        expense = Expense.objects.get(name="Test name")
        response = test_utils.delete(
            self.client, self.expense_url + "/" + str(expense.id)
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        # Delete expense data as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        response = test_utils.delete(
            self.client, self.expense_url + "/" + str(expense.id)
        )
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

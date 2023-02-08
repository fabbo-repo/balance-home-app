from django.utils.timezone import now, timedelta
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from expense.models import ExpenseType
from rest_framework import status
import core.tests.utils as test_utils


class ExpenseFilterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.expense_url = reverse('expense-list')
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code='EUR')
        self.user_data = {
            'username': "username",
            'email': "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
            'pref_coin_type': str(self.coin_type.code)
        }
        self.credentials = {
            'email': "email@test.com",
            "password": "password1@212"
        }
        self.user = self.create_user()
        self.exp_type = ExpenseType.objects.create(name="test")
        return super().setUp()

    def get_expense_data(self):
        return {
            'name': 'Test name',
            'description': 'Test description',
            'real_quantity': 2.5,
            'coin_type': self.coin_type.code,
            'exp_type': self.exp_type.name,
            'date': str(now().date()),
            'owner': str(self.user),
        }

    def create_user(self):
        user = User.objects.create(
            username=self.user_data['username'],
            email=self.user_data['email'],
            inv_code=self.inv_code,
            verified=True,
            pref_coin_type=self.coin_type,
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user

    def authenticate_add_expense(self):
        test_utils.authenticate_user(self.client, self.credentials)
        data = self.get_expense_data()
        # Add new expense
        test_utils.post(self.client, self.expense_url, data)

    def test_expense_filter_date(self):
        """
        Checks Expense filter by date
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url+'?date='+str(now().date())
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_expense_filter_date_from_to(self):
        """
        Checks Expense filter by date form to
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url+'?date_from=' \
            + str(
                now().date() - timedelta(days=1)
            )+'&date_to=' \
            + str(
                now().date() + timedelta(days=1)
            )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_expense_filter_exp_type(self):
        """
        Checks Expense filter by exp_type
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url+'?exp_type=test'
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_expense_filter_coin_type(self):
        """
        Checks Expense filter by coin_type
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url+'?coin_type=EUR'
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_expense_filter_quantity_min_and_max(self):
        """
        Checks Expense filter by quantity min and max
        """
        self.authenticate_add_expense()
        # Get expense data
        url = self.expense_url+'?converted_quantity_min=1.0&converted_quantity_max=3.0'
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        # Get expense data
        url = self.expense_url+'?converted_quantity_min=6.0&converted_quantity_max=8.0'
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 0)

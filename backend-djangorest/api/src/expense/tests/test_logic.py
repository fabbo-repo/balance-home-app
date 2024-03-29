from django.utils.timezone import now
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from expense.models import Expense, ExpenseType
import core.tests.utils as test_utils


class ExpenseLogicTests(APITestCase):
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

    def get_expense_data(self):
        return {
            'name': 'Test name',
            'description': '',
            'real_quantity': 2.0,
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
            balance=10,
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

    def test_expense_post(self):
        """
        Checks balance gets updated with Expense post
        """
        data = self.get_expense_data()
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.expense_url, data)
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 8)
        # Negative quantity not allowed
        data['real_quantity'] = -10.0
        response = test_utils.post(self.client, self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('real_quantity', [field["name"]
                      for field in response.data["fields"]])

    def test_expense_patch(self):
        """
        Checks balance gets updated with Expense patch (similar to put)
        """
        data = self.get_expense_data()
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.expense_url, data)
        expense = Expense.objects.get(name='Test name')
        # Patch method
        test_utils.patch(self.client, self.expense_url+'/'+str(expense.id),
                         {'real_quantity': 5.0})
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 5)

    def test_expense_delete_url(self):
        """
        Checks balance gets updated with Expense delete
        """
        # Add first expense
        data = self.get_expense_data()
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.expense_url, data)
        data2 = data
        data2['name'] = 'test'
        # Add second expense
        test_utils.post(self.client, self.expense_url, data2)
        expense = Expense.objects.get(name='Test name')
        # Delete second expense
        test_utils.delete(self.client, self.expense_url+'/'+str(expense.id))
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 8)

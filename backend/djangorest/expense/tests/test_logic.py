from django.utils.timezone import now
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from expense.models import Expense, ExpenseType


class ExpenseLogicTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.expense_url=reverse('expense-list')
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code='EUR')
        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
            'pref_coin_type': str(self.coin_type.code)
        }
        self.credentials = {
            'email':"email@test.com",
            "password": "password1@212"
        }
        self.user = self.create_user()
        self.exp_type = ExpenseType.objects.create(name="test")
    
    def get(self, url) :
        return self.client.get(url)
    
    def post(self, url, data={}) :
        return self.client.post(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def patch(self, url, data={}) :
        return self.client.patch(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def delete(self, url) :
        return self.client.delete(url)
    
    def authenticate_user(self, credentials):
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
    
    def get_expense_data(self):
        return {
            'name': 'Test name',
            'description': '',
            'quantity': 2.0,
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
            balance= 10,
            pref_coin_type=self.coin_type,
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user

    def authenticate_add_expense(self):
        self.authenticate_user(self.credentials)
        data = self.get_expense_data()
        # Add new expense
        self.post(self.expense_url, data)
    
    def test_expense_post(self):
        """
        Checks balance gets updated with Expense post
        """
        data = self.get_expense_data()
        self.authenticate_user(self.credentials)
        self.post(self.expense_url, data)
        user=User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 8)
        # Negative quantity not allowed
        data['quantity'] = -10.0
        response = self.post(self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('quantity', response.data)
    
    def test_expense_patch(self):
        """
        Checks balance gets updated with Expense patch (similar to put)
        """
        data = self.get_expense_data()
        self.authenticate_user(self.credentials)
        self.post(self.expense_url, data)
        expense = Expense.objects.get(name='Test name')
        # Patch method
        self.patch(self.expense_url+'/'+str(expense.id), {'quantity': 5.0})
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 5)

    def test_expense_delete_url(self):
        """
        Checks balance gets updated with Expense delete
        """
        # Add first expense
        data = self.get_expense_data()
        self.authenticate_user(self.credentials)
        self.post(self.expense_url, data)
        data2 = data
        data2['name']='test'
        # Add second expense
        self.post(self.expense_url, data2)
        expense = Expense.objects.get(name='Test name')
        # Delete second expense
        self.delete(self.expense_url+'/'+str(expense.id))
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 8)
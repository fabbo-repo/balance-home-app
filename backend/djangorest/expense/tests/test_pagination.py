from django.utils.timezone import now
import json
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from expense.models import ExpenseType


class ExpensePaginationTests(APITestCase):
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
        return super().setUp()
    
    def get(self, url) :
        return self.client.get(url)
    
    def post(self, url, data={}) :
        return self.client.post(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def authenticate_user(self, credentials):
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
    
    def get_expense_data(self):
        return {
            'name': 'Test name',
            'description': 'Test description',
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
            pref_coin_type=self.coin_type,
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user
    
    
    def test_expense_pagination_scheme(self):
        """
        Checks Expense pagination scheme is correct
        """
        data = self.get_expense_data()
        # Add new expense
        self.authenticate_user(self.credentials)
        self.post(self.expense_url, data)
        # Get expense data
        response = self.get(self.expense_url)
        scheme = dict(response.data)
        scheme['results'] = []
        results = dict(response.data)['results']
            
        for result in results:
            result = dict(result)
            result['exp_type'] = dict(result['exp_type'])
            scheme['results'] += [result]
        expected_scheme = {
            'count': 1, 'next': None, 'previous': None, 
            'results': [
                {
                    'id': 1, 
                    'name': 'Test name', 
                    'description': 'Test description', 
                    'real_quantity': 2.0, 
                    'converted_quantity': 2.0, 
                    'date': str(now().date()), 
                    'coin_type': 'EUR', 
                    'exp_type': {
                        'name': 'test',
                        'image': 'http://testserver/media/core/default_image.jpg'
                    }
                }
            ]
        }
        self.assertEqual(scheme, expected_scheme)

    def test_expense_two_pages(self):
        """
        Checks 2 pages of Expense data is correct
        """
        self.authenticate_user(self.credentials)
        for i in range(20):
            data = self.get_expense_data()
            # Add new expense
            self.post(self.expense_url, data)
        # Get First page expense data
        response = self.get(self.expense_url)
        data = dict(response.data)
        self.assertEqual(data['count'], 20)
        # 10 expenses in the first page
        self.assertEqual(len(data['results']), 10)
        # Second page
        response = self.get(data['next'])
        self.assertEqual(data['count'], 20)
        # 10 expenses in the first page
        self.assertEqual(len(data['results']), 10)
from django.utils.timezone import now
import json
from rest_framework.test import APITestCase
from django.urls import reverse
from balance.models import AnnualBalance, CoinType, MonthlyBalance
from custom_auth.models import InvitationCode, User
import logging


class DateBalancePaginationTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.annual_balance_list=reverse('annual-balance-list')
        self.monthly_balance_list=reverse('monthly-balance-list')
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code='EUR')
        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
        }
        self.credentials = {
            'email':"email@test.com",
            "password": "password1@212"
        }
        self.user = self.create_user()
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
    
    def get_annual_balance_data(self):
        return {
            'gross_quantity': 1.1,
            'net_quantity': 2.2,
            'coin_type': self.coin_type,
            'owner': self.user,
            'year': now().date().year
        }
    
    def get_monthly_balance_data(self):
        return {
            'gross_quantity': 1.1,
            'net_quantity': 2.2,
            'coin_type': self.coin_type,
            'owner': self.user,
            'year': now().date().year,
            'month': now().date().month
        }
    
    def create_user(self):
        user = User.objects.create(
            username=self.user_data['username'],
            email=self.user_data['email'],
            inv_code=self.inv_code,
            verified=True
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user

    def authenticate_add_annual_balance(self):
        self.authenticate_user(self.credentials)
        self.add_annual_balance()
    
    def add_annual_balance(self):
        data = self.get_annual_balance_data()
        AnnualBalance.objects.create(
            gross_quantity=data['gross_quantity'],
            net_quantity=data['net_quantity'],
            coin_type=data['coin_type'],
            owner=data['owner'],
            year=data['year'],
        )
    
    def authenticate_add_monthly_balance(self):
        self.authenticate_user(self.credentials)
        self.add_monthly_balance()
    
    def add_monthly_balance(self):
        data = self.get_monthly_balance_data()
        MonthlyBalance.objects.create(
            gross_quantity=data['gross_quantity'],
            net_quantity=data['net_quantity'],
            coin_type=data['coin_type'],
            owner=data['owner'],
            year=data['year'],
            month=data['month']
        )
    
    
    def test_annual_balance_pagination_scheme(self):
        """
        Checks AnnualBalance pagination scheme is correct
        """
        # Add new AnnualBalance
        self.authenticate_add_annual_balance()
        # Get AnnualBalance data
        response = self.get(self.annual_balance_list)
        scheme = dict(response.data)
        scheme['results'] = []
        results = dict(response.data)['results']
            
        for result in results:
            result.pop('created')
            scheme['results'] += [dict(result)]
        expected_scheme = {
            'count': 1, 'next': None, 'previous': None, 
            'results': [
                {
                    'gross_quantity': 1.1, 
                    'net_quantity': 2.2,
                    'coin_type': 'EUR',
                    'year': now().date().year
                }
            ]
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
        response = self.get(self.annual_balance_list)
        data = dict(response.data)
        self.assertEqual(data['count'], 20)
        # 10 AnnualBalance in the first page
        self.assertEqual(len(data['results']), 10)
        # Second page
        response = self.get(data['next'])
        self.assertEqual(data['count'], 20)
        # 10 AnnualBalance in the first page
        self.assertEqual(len(data['results']), 10)

    def test_monthly_balance_pagination_scheme(self):
        """
        Checks MonthlyBalance pagination scheme is correct
        """
        # Add new MonthlyBalance
        self.authenticate_add_monthly_balance()
        # Get MonthlyBalance data
        response = self.get(self.monthly_balance_list)
        scheme = dict(response.data)
        scheme['results'] = []
        results = dict(response.data)['results']
            
        for result in results:
            result.pop('created')
            scheme['results'] += [dict(result)]
        expected_scheme = {
            'count': 1, 'next': None, 'previous': None, 
            'results': [
                {
                    'gross_quantity': 1.1, 
                    'net_quantity': 2.2,
                    'coin_type': 'EUR',
                    'year': now().date().year,
                    'month': now().date().month
                }
            ]
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
        response = self.get(self.monthly_balance_list)
        data = dict(response.data)
        self.assertEqual(data['count'], 20)
        # 10 MonthlyBalance in the first page
        self.assertEqual(len(data['results']), 10)
        # Second page
        response = self.get(data['next'])
        self.assertEqual(data['count'], 20)
        # 10 MonthlyBalance in the first page
        self.assertEqual(len(data['results']), 10)
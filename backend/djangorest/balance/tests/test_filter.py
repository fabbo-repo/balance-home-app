from django.utils.timezone import now
import json
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from balance.models import AnnualBalance, MonthlyBalance
from rest_framework import status


class DateBalanceFilterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.annual_balance_list=reverse('annual-balance-list')
        self.monthly_balance_list=reverse('monthly-balance-list')
        self.coin_type = CoinType.objects.create(code='EUR')
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
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
            'expected_quantity': 2.2,
            'coin_type': self.coin_type,
            'owner': self.user,
            'year': now().date().year
        }
    
    def get_monthly_balance_data(self):
        return {
            'gross_quantity': 1.1,
            'expected_quantity': 2.2,
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
        data = self.get_annual_balance_data()
        AnnualBalance.objects.create(
            gross_quantity=data['gross_quantity'],
            expected_quantity=data['expected_quantity'],
            coin_type=data['coin_type'],
            owner=data['owner'],
            year=data['year'],
        )
    
    def authenticate_add_monthly_balance(self):
        self.authenticate_user(self.credentials)
        data = self.get_monthly_balance_data()
        MonthlyBalance.objects.create(
            gross_quantity=data['gross_quantity'],
            expected_quantity=data['expected_quantity'],
            coin_type=data['coin_type'],
            owner=data['owner'],
            year=data['year'],
            month=data['month']
        )
    
    
    def test_annual_balance_filter_coin_type(self):
        """
        Checks AnnualBalance filter by coin_type
        """
        self.authenticate_add_annual_balance()
        url = self.annual_balance_list+'?coin_type=EUR'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_monthly_balance_filter_coin_type(self):    
        """
        Checks MonthlyBalance filter by coin_type
        """
        self.authenticate_add_monthly_balance()
        url = self.monthly_balance_list+'?coin_type=EUR'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
    
    def test_annual_balance_filter_gross_quantity_min_and_max(self):
        """
        Checks AnnualBalance filter by gross_quantity min and max
        """
        self.authenticate_add_annual_balance()
        url = self.annual_balance_list+'?gross_quantity_min=1.0&gross_quantity_max=3.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        url = self.annual_balance_list+'?gross_quantity_min=6.0&gross_quantity_max=8.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 0)

    def test_monthly_balance_filter_gross_quantity_min_and_max(self):
        """
        Checks MonthlyBalance filter by gross_quantity min and max
        """
        self.authenticate_add_monthly_balance()
        url = self.monthly_balance_list+'?gross_quantity_min=1.0&gross_quantity_max=3.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        url = self.monthly_balance_list+'?gross_quantity_min=6.0&gross_quantity_max=8.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 0)
    
    def test_annual_balance_filter_expected_quantity_min_and_max(self):
        """
        Checks AnnualBalance filter by expected_quantity min and max
        """
        self.authenticate_add_annual_balance()
        url = self.annual_balance_list+'?expected_quantity_min=1.0&expected_quantity_max=3.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        url = self.annual_balance_list+'?expected_quantity_min=6.0&expected_quantity_max=8.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 0)

    def test_monthly_balance_filter_expected_quantity_min_and_max(self):
        """ 
        Checks MonthlyBalance filter by expected_quantity min and max
        """
        self.authenticate_add_monthly_balance()
        url = self.monthly_balance_list+'?expected_quantity_min=1.0&expected_quantity_max=3.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        url = self.monthly_balance_list+'?expected_quantity_min=6.0&expected_quantity_max=8.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 0)
    
    def test_annual_balance_filter_year(self):
        """
        Checks AnnualBalance filter by year
        """
        self.authenticate_add_annual_balance()
        url = self.annual_balance_list+'?year='+str(now().date().year)
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
    
    def test_annual_monthly_filter_year(self):
        """
        Checks MonthlyBalance filter by year
        """
        self.authenticate_add_monthly_balance()
        url = self.monthly_balance_list+'?year='+str(now().date().year)
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_annual_monthly_filter_year(self):
        """
        Checks MonthlyBalance filter by month
        """
        self.authenticate_add_monthly_balance()
        url = self.monthly_balance_list+'?month='+str(now().date().month)
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
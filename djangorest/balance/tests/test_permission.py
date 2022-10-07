from collections import OrderedDict
from django.utils.timezone import now
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from balance.models import AnnualBalance, CoinType, MonthlyBalance
from custom_auth.models import InvitationCode, User
import logging
from expense.models import Expense, ExpenseType


class DateBalancePermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.annual_balance_list=reverse('annual-balance-list')
        self.monthly_balance_list=reverse('monthly-balance-list')
        
        # Create InvitationCodes
        self.inv_code1 = InvitationCode.objects.create()
        self.inv_code2 = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code='EUR')
        # Test user data
        self.user_data1={
            'username':"username1",
            'email':"email1@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code1.code)
        }
        self.user_data2={
            'username':"username2",
            'email':"email2@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code2.code)
        }
        self.credentials1 = {
            'email':"email1@test.com",
            "password": "password1@212"
        }
        self.credentials2 = {
            'email':"email2@test.com",
            "password": "password1@212"
        }
        # User creation
        self.user1 = User.objects.create(
            username=self.user_data1["username"],
            email=self.user_data1["email"],
            inv_code=self.inv_code1,
            verified=True
        )
        self.user1.set_password(self.user_data1['password'])
        self.user1.save()
        self.user2 = User.objects.create(
            username=self.user_data2["username"],
            email=self.user_data2["email"],
            inv_code=self.inv_code2,
            verified=True
        )
        self.user2.set_password(self.user_data2['password'])
        self.user2.save()
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
    
    def get_annual_balance_data(self, user):
        return {
            'gross_quantity': 1.1,
            'net_quantity': 2.2,
            'coin_type': self.coin_type,
            'owner': user,
            'year': now().date().year
        }
    
    def get_monthly_balance_data(self, user):
        return {
            'gross_quantity': 1.1,
            'net_quantity': 2.2,
            'coin_type': self.coin_type,
            'owner': user,
            'year': now().date().year,
            'month': now().date().month
        }
    
    def add_annual_balance(self, user):
        data = self.get_annual_balance_data(user)
        return AnnualBalance.objects.create(
            gross_quantity=data['gross_quantity'],
            net_quantity=data['net_quantity'],
            coin_type=data['coin_type'],
            owner=data['owner'],
            year=data['year'],
        ).id
    
    def add_monthly_balance(self, user):
        data = self.get_monthly_balance_data(user)
        return MonthlyBalance.objects.create(
            gross_quantity=data['gross_quantity'],
            net_quantity=data['net_quantity'],
            coin_type=data['coin_type'],
            owner=data['owner'],
            year=data['year'],
            month=data['month']
        ).id


    def test_annual_balance_get_list_url(self):
        """
        Checks permissions with AnnualBalance get and list
        """
        self.authenticate_user(self.credentials1)
        # Add new AnnualBalance as user1
        id = self.add_annual_balance(self.user1)
        # Get AnnualBalance data as user1
        response = self.get(self.annual_balance_list)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 1)
        # Get AnnualBalance data as user2
        self.authenticate_user(self.credentials2)
        response = self.get(self.annual_balance_list)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 0)
        # Try with an specific expense
        response = self.get(self.annual_balance_list+'/'+str(id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_monthly_balance_get_list_url(self):
        """
        Checks permissions with MonthlyBalance get and list
        """
        self.authenticate_user(self.credentials1)
        # Add new MonthlyBalance as user1
        id = self.add_monthly_balance(self.user1)
        # Get MonthlyBalance data as user1
        response = self.get(self.monthly_balance_list)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 1)
        # Get MonthlyBalance data as user2
        self.authenticate_user(self.credentials2)
        response = self.get(self.monthly_balance_list)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 0)
        # Try with an specific expense
        response = self.get(self.monthly_balance_list+'/'+str(id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
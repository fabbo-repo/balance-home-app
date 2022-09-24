from datetime import date, timedelta
import json
from rest_framework.test import APITestCase
from django.urls import reverse
from balance.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from revenue.models import Revenue, RevenueType
from rest_framework import status


class RevenueFilterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.revenue_url=reverse('revenue-list')
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.inv_code.save()
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
        
        self.coin_type = self.create_coin_type()
        self.rev_type = self.create_rev_type()
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
    
    def get_revenue_data(self):
        return {
            'name': 'Test name',
            'description': 'Test description',
            'quantity': 2.6,
            'coin_type': self.coin_type.code,
            'rev_type': self.rev_type.name,
            'date': str(date.today()),
            'owner': str(self.user),
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
    
    def create_rev_type(self):
        rev_type = RevenueType.objects.create(name="test")
        rev_type.save()
        return rev_type
    
    def create_coin_type(self):
        coin_type = CoinType.objects.create(code='EUR', name='euro')
        coin_type.save()
        return coin_type

    def authenticate_add_revenue(self):
        self.authenticate_user(self.credentials)
        data = self.get_revenue_data()
        # Add new revenue
        self.post(self.revenue_url, data)
    

    """
    Checks Revenue filter by date
    """
    def test_revenue_filter_date(self):
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?date='+str(date.today())
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        
    """
    Checks Revenue filter by date form to
    """
    def test_revenue_filter_date_from_to(self):
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?date_from=' \
            +str(
                date.today() - timedelta(days=1)
            )+'&date_to=' \
            +str(
                date.today() + timedelta(days=1)
            )
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
    
    """
    Checks Revenue filter by rev_type
    """
    def test_revenue_filter_rev_type(self):
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?rev_type=test'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    """
    Checks Revenue filter by coin_type
    """
    def test_revenue_filter_coin_type(self):
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?coin_type=EUR'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
    
    """
    Checks Revenue filter by quantity min and max
    """
    def test_revenue_filter_quantity_min_and_max(self):
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?quantity_min=1.0&quantity_max=3.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        # Get revenue data
        url = self.revenue_url+'?quantity_min=6.0&quantity_max=8.0'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 0)
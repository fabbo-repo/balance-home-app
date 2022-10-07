from django.utils.timezone import now, timedelta
import json
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from revenue.models import RevenueType
from rest_framework import status


class RevenueFilterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.revenue_url=reverse('revenue-list')
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
        self.rev_type = RevenueType.objects.create(name="test")
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

    def authenticate_add_revenue(self):
        self.authenticate_user(self.credentials)
        data = self.get_revenue_data()
        # Add new revenue
        self.post(self.revenue_url, data)
    

    def test_revenue_filter_date(self):
        """
        Checks Revenue filter by date
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?date='+str(now().date())
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
        
    def test_revenue_filter_date_from_to(self):
        """
        Checks Revenue filter by date form to
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?date_from=' \
            +str(
                now().date() - timedelta(days=1)
            )+'&date_to=' \
            +str(
                now().date() + timedelta(days=1)
            )
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
    
    def test_revenue_filter_rev_type(self):
        """
        Checks Revenue filter by rev_type
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?rev_type=test'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)

    def test_revenue_filter_coin_type(self):
        """
        Checks Revenue filter by coin_type
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+'?coin_type=EUR'
        response = self.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data['count'], 1)
    
    def test_revenue_filter_quantity_min_and_max(self):
        """
        Checks Revenue filter by quantity min and max
        """
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
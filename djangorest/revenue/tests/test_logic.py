from collections import OrderedDict
from datetime import date
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from balance.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from django.conf import settings
from revenue.models import Revenue, RevenueType


class RevenueLogicTests(APITestCase):
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
    
    def get_revenue_data(self):
        return {
            'name': 'Test name',
            'description': 'Test description',
            'quantity': 2.0,
            'coin_type': self.coin_type.simb,
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
        coin_type = CoinType.objects.create(simb='EUR', name='euro')
        coin_type.save()
        return coin_type

    def authenticate_add_revenue(self):
        self.authenticate_user(self.credentials)
        data = self.get_revenue_data()
        # Add new revenue
        self.post(self.revenue_url, data)
    
    """
    Checks balance gets updated with Revenue post
    """
    def test_revenue_post(self):
        data = self.get_revenue_data()
        self.authenticate_user(self.credentials)
        response=self.post(self.revenue_url, data)
        user=User.objects.get(email=self.user_data['email'])
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Compare owner
        revenue = Revenue.objects.get(name="Test name")
        self.assertEqual(revenue.owner.email, self.user_data1['email'])

    """
    Checks permissions with Revenue get
    """
    def test_revenue_get_url(self):
        data = self.get_revenue_data()
        # Add new revenue as user1
        self.authenticate_user(self.credentials1)
        self.post(self.revenue_url, data)
        # Get revenue data as user1
        response = self.get(self.revenue_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Get revenue data as user2
        self.authenticate_user(self.credentials2)
        response = self.get(self.revenue_url)
        # Gets an empty dict
        self.assertEqual(response.data, 
            OrderedDict([('count', 0), ('next', None), ('previous', None), ('results', [])]))
        # Try with an specific revenue
        revenue = Revenue.objects.get(name='Test name')
        response = self.get(self.revenue_url+'/'+str(revenue.id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    """
    Checks permissions with Revenue patch (almost same as put)
    """
    def test_revenue_put_url(self):
        data = self.get_revenue_data()
        # Add new revenue as user1
        self.authenticate_user(self.credentials1)
        self.post(self.revenue_url, data)
        revenue = Revenue.objects.get(name='Test name')
        # Try update as user1
        response=self.patch(self.revenue_url+'/'+str(revenue.id), {'quantity': 35.0})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check revenue
        revenue = Revenue.objects.get(name='Test name')
        self.assertEqual(revenue.quantity, 35.0)
        # Try update as user2
        self.authenticate_user(self.credentials2)
        response=self.patch(self.revenue_url+'/'+str(revenue.id), {'quantity': 30.0})
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    """
    Checks permissions with Revenue delete
    """
    def test_revenue_delete_url(self):
        data = self.get_revenue_data()
        # Add new revenue as user1
        self.authenticate_user(self.credentials1)
        self.post(self.revenue_url, data)
        # Delete revenue data as user2
        self.authenticate_user(self.credentials2)
        revenue = Revenue.objects.get(name='Test name')
        response = self.delete(self.revenue_url+'/'+str(revenue.id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        # Delete revenue data as user1
        self.authenticate_user(self.credentials1)
        response = self.delete(self.revenue_url+'/'+str(revenue.id))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
from datetime import date
import json
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from revenue.models import RevenueType


class RevenuePaginationTests(APITestCase):
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
            'quantity': 2.0,
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
            verified=True,
            pref_coin_type=self.coin_type,
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user
        
    
    """
    Checks Revenue pagination scheme is correct
    """
    def test_revenue_pagination_scheme(self):
        data = self.get_revenue_data()
        # Add new revenue
        self.authenticate_user(self.credentials)
        self.post(self.revenue_url, data)
        # Get revenue data
        response = self.get(self.revenue_url)
        scheme = dict(response.data)
        scheme['results'] = []
        results = dict(response.data)['results']
            
        for result in results:
            result = dict(result)
            result['rev_type'] = dict(result['rev_type'])
            scheme['results'] += [result]
        expected_scheme = {
            'count': 1, 'next': None, 'previous': None, 
            'results': [
                {
                    'id': 1, 
                    'name': 'Test name', 
                    'description': 'Test description', 
                    'quantity': 2.0, 
                    'date': str(date.today()), 
                    'coin_type': 'EUR', 
                    'rev_type': {
                        'name': 'test',
                        'image': 'http://testserver/media/core/default_image.jpg'
                    }
                }
            ]
        }
        self.assertEqual(scheme, expected_scheme)

    """
    Checks 2 pages of Revenue data is correct
    """
    def test_revenue_two_pages(self):
        self.authenticate_user(self.credentials)
        for i in range(20):
            data = self.get_revenue_data()
            # Add new revenue
            self.post(self.revenue_url, data)
        # Get First page revenue data
        response = self.get(self.revenue_url)
        data = dict(response.data)
        self.assertEqual(data['count'], 20)
        # 10 revenues in the first page
        self.assertEqual(len(data['results']), 10)
        # Second page
        response = self.get(data['next'])
        self.assertEqual(data['count'], 20)
        # 10 revenues in the first page
        self.assertEqual(len(data['results']), 10)
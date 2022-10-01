from django.utils.timezone import now
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from revenue.models import Revenue, RevenueType


class RevenuePermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.revenue_url=reverse('revenue-list')
        self.rev_type_list_url=reverse('rev_type_list')
        
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
            'inv_code': str(self.inv_code1.code),
            'pref_coin_type': str(self.coin_type.code)
        }
        self.user_data2={
            'username':"username2",
            'email':"email2@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code2.code),
            'pref_coin_type': str(self.coin_type.code)
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
        user1 = User.objects.create(
            username=self.user_data1["username"],
            email=self.user_data1["email"],
            inv_code=self.inv_code1,
            verified=True,
            pref_coin_type=self.coin_type
        )
        user1.set_password(self.user_data1['password'])
        user1.save()
        user2 = User.objects.create(
            username=self.user_data2["username"],
            email=self.user_data2["email"],
            inv_code=self.inv_code2,
            verified=True,
            pref_coin_type=self.coin_type
        )
        user2.set_password(self.user_data2['password'])
        user2.save()
        return super().setUp()
    
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
    
    def get_revenue_type_data(self):
        rev_type = RevenueType.objects.create(name='test')
        return {
            'name': rev_type.name,
            'image': rev_type.image
        }
    
    def get_revenue_data(self):
        rev_type = self.get_revenue_type_data()
        return {
            'name': 'Test name',
            'description': 'Test description',
            'quantity': 2.0,
            'coin_type': self.coin_type.code,
            'rev_type': rev_type['name'],
            'date': str(now().date())
        }


    """
    Checks permissions with Revenue Type get and list
    """
    def test_revenue_type_get_list_url(self):
        data = self.get_revenue_type_data()
        # Get revenue type data without authentication
        response = self.get(self.rev_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with an specific revenue
        response = self.get(self.rev_type_list_url+'/'+str(data['name']))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get revenue type data with authentication
        self.authenticate_user(self.credentials1)
        response = self.get(self.rev_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Try with an specific revenue
        response = self.get(self.rev_type_list_url+'/'+str(data['name']))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    """
    Checks permissions with Revenue post
    """
    def test_revenue_post_url(self):
        data = self.get_revenue_data()
        # Try without authentication
        response=self.post(self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with authentication
        self.authenticate_user(self.credentials1)
        response=self.post(self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Compare owner
        revenue = Revenue.objects.get(name="Test name")
        self.assertEqual(revenue.owner.email, self.user_data1['email'])

    """
    Checks permissions with Revenue get and list
    """
    def test_revenue_get_list_url(self):
        data = self.get_revenue_data()
        # Add new revenue as user1
        self.authenticate_user(self.credentials1)
        self.post(self.revenue_url, data)
        # Get revenue data as user1
        response = self.get(self.revenue_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 1)
        # Get revenue data as user2
        self.authenticate_user(self.credentials2)
        response = self.get(self.revenue_url)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 0)
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
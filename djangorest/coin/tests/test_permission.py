import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from coin.currency_converter_integration import update_exchange_data


class CoinPermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.coin_type_list_url=reverse('coin_type_list')
        self.coin_exchange_list_url=reverse('coin_exchange_list', args=['1'])
        self.coin_exchange_code_url=reverse('coin_exchange_code', args=['EUR'])
        
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
            verified=True
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


    def test_coin_type_get_url(self):
        """
        Checks permissions with Coin Type get
        """
        # Try with an specific coin
        response = self.get(self.coin_type_list_url+'/'+str(self.coin_type.code))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with an specific coin with authentication
        self.authenticate_user(self.credentials1)
        response = self.get(self.coin_type_list_url+'/'+str(self.coin_type.code))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_coin_type_list_url(self):
        """
        Checks permissions with Coin Type list
        """
        # List coin type data without authentication
        response = self.get(self.coin_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # List coin type data with authentication
        self.authenticate_user(self.credentials1)
        response = self.get(self.coin_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_coin_exchange_list_url(self):
        """
        Checks permissions with Coin Exchange list
        """
        # List coin exchange list without authentication
        response = self.get(self.coin_exchange_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # List coin exchange list with authentication
        self.authenticate_user(self.credentials1)
        response = self.get(self.coin_exchange_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_coin_exchange_code_url(self):
        """
        Checks permissions with Coin Exchange code
        """
        update_exchange_data()
        # List coin exchange list without authentication
        response = self.get(self.coin_exchange_code_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # List coin exchange list with authentication
        self.authenticate_user(self.credentials1)
        response = self.get(self.coin_exchange_code_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

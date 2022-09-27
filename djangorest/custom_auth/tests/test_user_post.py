from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import User, InvitationCode
import logging
import json

class UserPostTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.user_post_url=reverse('user_post')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        self.inv_code.save()
        # Test user data
        self.user_data={
            "username":"username",
            "email":"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            "inv_code": str(self.inv_code.code),
            'pref_coin_type': 
                str(CoinType.objects.create(code='EUR').code),
            'language': 'en'
        }
        return super().setUp()

    def user_post(self, user_data=None) :
        if user_data == None: user_data = self.user_data
        return self.client.post(
            self.user_post_url,
            data=json.dumps(user_data),
            content_type="application/json"
        )
    

    """
    Checks that an user with user_post url is created
    """
    def test_user(self):
        response=self.user_post()
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        new_user = User.objects.get(email=self.user_data['email'])
        self.assertIsNotNone(new_user)
    
    """
    Checks that an user with an used username is not created
    """
    def test_two_user_with_username(self):
        # User 1 creation
        self.user_post()
        # User 2 creation
        user_data2 = self.user_data
        user_data2['email'] = 'email2@test.com'
        response=self.user_post(user_data2)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['username'][0], 'This field must be unique.')

    """
    Checks that an user with an used email is not created
    """
    def test_two_user_with_email(self):
        # User 1 creation
        self.user_post()
        # User 2 creation
        user_data2 = self.user_data
        user_data2['username'] = 'username2'
        response=self.user_post(user_data2)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['email'][0], 'This field must be unique.')
    
    """
    Checks that an user with no data is not created
    """
    def test_empty_user(self):
        response=self.user_post({})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)
        self.assertIn('username', response.data)
        self.assertIn('password', response.data)
        self.assertIn('password2', response.data)
        self.assertIn('inv_code', response.data)
        self.assertIn('pref_coin_type', response.data)
        self.assertIn('language', response.data)
    
    """
    Checks that an user with no email is not created
    """
    def test_none_email(self):
        response=self.user_post(
            {
                'username': self.user_data['username'],
                'inv_code': self.user_data['inv_code'],
                "password": self.user_data['password'],
                "password2": self.user_data['password2']
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    """
    Checks that an user with no username is not created
    """
    def test_none_username(self):
        response=self.user_post(
            {
                'email': self.user_data['email'],
                'inv_code': self.user_data['inv_code'],
                "password": self.user_data['password'],
                "password2": self.user_data['password2']
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('username', response.data)
    
    """
    Checks that an user with diferent passwords is not created
    """
    def test_different_passwords(self):
        data = self.user_data
        data["password2"] = 'pass12'
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['password'][0], "Password fields do not match")
    
    """
    Checks that an user with a short password is not created
    """
    def test_short_password(self):
        data = self.user_data
        data["password"] = 'admin'
        data["password2"] = 'admin'
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
    
    """
    Checks that an user with a too common password is not created
    """
    def test_common_password(self):
        data = self.user_data
        data["password"] = 'admin1234'
        data["password2"] = 'admin1234'
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
    
    """
    Checks that an user with a too common password is not created
    """
    def test_only_username_user_post(self):
        data = self.user_data
        data["username"] = 'username@1L24'
        data["password"] = 'username@1L24'
        data["password2"] = 'username@1L24'
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
        
    """
    Checks that an user with a numeric password is not created
    """
    def test_only_username_user_post(self):
        data = self.user_data
        data["password"] = '12345678'
        data["password2"] = '12345678'
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
    
    """
    Checks that an user with same email and username is not created
    """
    def test_same_email_username(self):
        data = self.user_data
        data["username"] = self.user_data['email']
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('common_fields', response.data)
    
    """
    Checks that an user with a wrong language is not created
    """
    def test_wrong_language(self):
        data = self.user_data
        data["language"] = "lm"
        response=self.user_post(data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('language', response.data)
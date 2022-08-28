from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from custom_auth.models import User
import logging

class RegisterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.register_url=reverse('register')

        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212",
            "password2": "password1@212"
        }
        return super().setUp()


    """
    Checks that an User with register url is created
    """
    def test_user(self):
        response=self.client.post(
            self.register_url,
            self.user_data
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        new_user = User.objects.get(email=self.user_data['email'])
        self.assertIsNotNone(new_user)

    """
    Checks that an user with an used username is not created
    """
    def test_two_user_with_username(self):
        # User 1 creation
        self.client.post(
            self.register_url,
            self.user_data
        )
        # User 2 creation
        user_data2 = self.user_data
        user_data2['email'] = 'email2@test.com'
        response=self.client.post(
            self.register_url,
            user_data2
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['username'][0], 'This field must be unique.')

    """
    Checks that an user with an used email is not created
    """
    def test_two_user_with_email(self):
        # User 1 creation
        self.client.post(
            self.register_url,
            self.user_data
        )
        # User 2 creation
        user_data2 = self.user_data
        user_data2['username'] = 'username2'
        response=self.client.post(
            self.register_url,
            user_data2
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['email'][0], 'This field must be unique.')
    
    """
    Checks that an user with no data is not created
    """
    def test_empty_user(self):
        response=self.client.post(
            self.register_url,
            {}
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)
        self.assertIn('username', response.data)
        self.assertIn('password', response.data)
        self.assertIn('password2', response.data)
    
    """
    Checks that an user with no email is not created
    """
    def test_none_email(self):
        response=self.client.post(
            self.register_url,
            {
                'username': self.user_data['username'],
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
        response=self.client.post(
            self.register_url,
            {
                'email': self.user_data['email'],
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
        response=self.client.post(
            self.register_url,
            {
                'username': self.user_data['username'],
                'email': self.user_data['email'],
                "password": self.user_data['password'],
                "password2": 'pass12'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['password'][0], "Password fields didn't match.")
    
    """
    Checks that an user with a short password is not created
    """
    def test_short_password(self):
        response=self.client.post(
            self.register_url,
            {
                'username': self.user_data['username'],
                'email': self.user_data['email'],
                "password": 'admin',
                "password2": 'admin'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
    
    """
    Checks that an user with a too common password is not created
    """
    def test_common_password(self):
        response=self.client.post(
            self.register_url,
            {
                'username': self.user_data['username'],
                'email': self.user_data['email'],
                "password": 'admin1234',
                "password2": 'admin1234'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
    
    """
    Checks that an user with a too common password is not created
    """
    def test_only_username_register(self):
        response=self.client.post(
            self.register_url,
            {
                'username': 'username@1L24',
                'email': self.user_data['email'],
                "password": 'username@1L24',
                "password2": 'username@1L24'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
        
    """
    Checks that an user with a numeric password is not created
    """
    def test_only_username_register(self):
        response=self.client.post(
            self.register_url,
            {
                'username': self.user_data['username'],
                'email': self.user_data['email'],
                "password": '12345678',
                "password2": '12345678'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', response.data)
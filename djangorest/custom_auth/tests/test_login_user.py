from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from custom_auth.models import User
import logging

class LoginTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.jwt_refresh_url=reverse('jwt_refresh')

        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212",
            "password2": "password1@212"
        }
        # Register User:
        self.client.post(
            reverse('register'),
            self.user_data
        )
        return super().setUp()


    """
    Checks that an unverified user should not be able to login
    """
    def test_login_unverified_user(self):
        response=self.client.post(
            self.jwt_obtain_url,
            self.user_data
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)



"""
* Must try login an inactive user
* Must try login an inexistant user
* Must try login an unverified user
* Must try send wrong email code
* Must try send invalid code
* Must try resend code

    def test_logins_user(self):
        user=self.register_user()
        response=self.client.post(self.login_url, {'email':user.email,'password':self.user_data['password']})
        self.assertEqual(response.status_code,status.HTTP_200_OK)
        self.assertIsInstance(response.data['token'],str)

    def test_gives_descriptive_errors_on_login(self):
        response=self.client.post(self.login_url, {'email':'test@site.com','password':self.user_data['password']})
        self.assertEqual(response.status_code,status.HTTP_401_UNAUTHORIZED)
        """
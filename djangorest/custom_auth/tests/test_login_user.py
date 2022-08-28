from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from custom_auth.models import InvitationCode, User
import logging

class LoginTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.jwt_refresh_url=reverse('jwt_refresh')

        # Create InvitationCode
        inv_code = InvitationCode.objects.create()
        inv_code.save()
        # Test user data
        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': inv_code.code
        }
        self.credentials = {
            'email':"email@test.com",
            "password": "password1@212"
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
            self.credentials
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('verified', response.data)

    """
    Checks that an inactive user should not be able to login
    """
    def test_login_inactive_user(self):
        user=User.objects.get(email=self.user_data['email'])
        user.is_active=False
        user.save()
        response=self.client.post(
            self.jwt_obtain_url,
            self.credentials
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data['detail'], 'No active account found with the given credentials')

    """
    Checks that an nonexistent user should not be able to login
    """
    def test_login_nonexistent_user(self):
        credentials2 = {
            'email':"none@none.com",
            "password": "password1@212"
        }
        response=self.client.post(
            self.jwt_obtain_url,
            credentials2
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data['detail'], 'No active account found with the given credentials')

    """
    Checks that an user without inv_code should not be able to login
    """
    def test_login_user_without_inv_code(self):
        user_data2 = {
            'username':"username2",
            'email':"email2@test.com",
            "password": "password1@212",
        }
        user = User.objects.create_user(**user_data2)
        user.set_password(user_data2['password'])
        user.save()
        credentials2={
            'email':"email2@test.com",
            "password": "password1@212",
        }
        response=self.client.post(
            self.jwt_obtain_url,
            credentials2
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('inv_code', response.data)


"""
* Must try send wrong email code
* Must try send invalid code
* Must try resend code
        """
import time
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from django.conf import settings
from django.core.cache import cache
import core.tests.utils as test_utils
from unittest import mock


class JwtCodeTests(APITestCase):
    def setUp(self):
        # Mock Celery tasks
        settings.CELERY_TASK_ALWAYS_EAGER = True
        mock.patch("custom_auth.tasks.notifications.send_email_code",
                   return_value=None)
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)
        # Throttling is stored in cache
        cache.clear()

        self.user_post_url = reverse('user_post')
        self.email_code_send_url = reverse('email_code_send')
        self.email_code_verify_url = reverse('email_code_verify')

        # Create InvitationCode
        inv_code = InvitationCode.objects.create()
        # Create CoinType
        coin_type = CoinType.objects.create(code='EUR')
        # Test user data
        self.user_data = {
            'username': "username",
            'email': "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(inv_code.code),
            'pref_coin_type': str(coin_type.code),
            "expected_annual_balance": 10.0,
            "expected_monthly_balance": 10.0,
            'language': 'en'
        }
        self.credentials = {
            'email': "email@test.com",
            "password": "password1@212"
        }
        # User creation
        user = User.objects.create(
            username=self.user_data["username"],
            email=self.user_data["email"],
            inv_code=inv_code,
            verified=False,
            pref_coin_type=coin_type,
            expected_annual_balance=self.user_data["expected_annual_balance"],
            expected_monthly_balance=self.user_data["expected_monthly_balance"],
            language=self.user_data["language"]
        )
        user.set_password(self.user_data['password'])
        user.save()
        return super().setUp()

    def send_code(self, email=None):
        if email == None:
            email = self.user_data['email']
        return test_utils.post(
            self.client,
            self.email_code_send_url,
            data={'email': email}
        )

    def verify_code(self, code, email=None):
        if email == None:
            email = self.user_data['email']
        return test_utils.post(
            self.client,
            self.email_code_verify_url,
            data={'email': email, 'code': code}
        )

    def test_jwt_obtain_unverified_user(self):
        """
        Checks that an unverified user should not be able to obtain jwt
        """
        response = test_utils.authenticate_user(self.client, self.credentials)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('verified', response.data)

    def test_jwt_obtain_inactive_user(self):
        """
        Checks that an inactive user should not be able to obtain jwt
        """
        user = User.objects.get(email=self.user_data['email'])
        user.is_active = False
        user.save()
        response = test_utils.authenticate_user(self.client, self.credentials)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(
            response.data['detail'], 'No active account found with the given credentials')

    def test_jwt_obtain_nonexistent_user(self):
        """
        Checks that an nonexistent user should not be able to obtain jwt
        """
        credentials2 = {
            'email': "none@none.com",
            "password": "password1@212"
        }
        response = test_utils.authenticate_user(self.client, credentials2)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(
            response.data['detail'], 'No active account found with the given credentials')

    def test_jwt_obtain_user_without_inv_code(self):
        """
        Checks that an user without inv_code should not be able to obtain jwt
        """
        user_data2 = {
            'username': "username2",
            'email': "email2@test.com",
            "password": "password1@212",
        }
        user = User.objects.create_user(**user_data2)
        user.set_password(user_data2['password'])
        user.save()
        credentials2 = {
            'email': "email2@test.com",
            "password": "password1@212",
        }
        response = test_utils.authenticate_user(self.client, credentials2)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('inv_code', response.data)

    def test_send_code_wrong_email(self):
        """
        Checks that a wrong user email should not be able to get a code
        """
        response = self.send_code("email_false@test.com")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    def test_send_code_right_email(self):
        """
        Checks that a right user email (unverified) should be able to get a code
        """
        response = self.send_code()
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_send_code_too_many_times(self):
        """
        Checks that requesting a second code at same time should not be right
        """
        self.send_code()
        response = self.send_code()
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_send_wrong_code(self):
        """
        Checks that sending a wrong code should not modify the user as verified
        """
        # Code generation first:
        self.send_code()
        response = self.verify_code('123')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        response = self.verify_code('123456')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'][0], 'Invalid code')

    def test_send_right_code(self):
        """
        Checks that sending a right code should modify the user as verified
        """
        # Code generation first:
        self.send_code()
        # Get enerated code
        code = User.objects.get(email=self.user_data['email']).code_sent
        response = self.verify_code(str(code))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_send_invalid_code(self):
        """
        Checks that sending an invalid code should not modify the user as verified
        """
        # Code generation first:
        self.send_code()
        # Set code validity to 1 second
        settings.EMAIL_CODE_VALID = 1
        # Get generated code
        code = User.objects.get(email=self.user_data['email']).code_sent
        # Sleep for 2 seconds
        time.sleep(2)
        # Verify invalid code
        response = self.verify_code(str(code))
        # Undo changes
        settings.EMAIL_CODE_VALID = 120
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'][0], 'Code is no longer valid')

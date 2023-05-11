import uuid
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import User, InvitationCode
import logging
import core.tests.utils as test_utils


class InvitationCodeTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.user_post_url = reverse('user_post')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        # Test user data
        self.user_data = {
            'username': "username",
            'email': "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
            'pref_coin_type':
                str(CoinType.objects.create(code='EUR').code),
            'language': 'en'
        }
        return super().setUp()

    def user_post(self, user_data=None):
        if user_data == None:
            user_data = self.user_data
        return test_utils.post(
            self.client,
            self.user_post_url,
            data=user_data
        )

    def test_inv_code_update(self):
        """
        Checks that an invitation code gets updated after user registration
        """
        self.user_post()
        User.objects.get(email=self.user_data['email'])
        # Cheks if InvitationCode gets updated
        self.assertFalse(InvitationCode.objects.get(
            code=self.inv_code.code).is_active)

    def test_user_with_inactive_inv_code(self):
        """
        Checks that an user with inactive invitation code is not created
        """
        # Create inactive InvitationCode
        inv_code2 = InvitationCode.objects.create(
            is_active=False,
            usage_left=0
        )
        # Test user data 2
        user_data2 = {
            'username': "username",
            'email': "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(inv_code2.code)
        }

        response = self.user_post(user_data2)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('inv_code', [field["name"]
                      for field in response.data["fields"]])

    def test_wrong_inv_code(self):
        """
        Checks that an user with no inv_code is not created
        """
        response = self.user_post(
            {
                'inv_cod': str(uuid.uuid4()),
                'username': self.user_data['username'],
                'email': self.user_data['email'],
                "password": self.user_data['password'],
                "password2": self.user_data['password2']
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('inv_code', [field["name"]
                      for field in response.data["fields"]])

    def test_none_inv_code(self):
        """
        Checks that an user with no inv_code is not created
        """
        response = self.user_post(
            {
                'username': self.user_data['username'],
                'email': self.user_data['email'],
                "password": self.user_data['password'],
                "password2": self.user_data['password2']
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('inv_code', [field["name"]
                      for field in response.data["fields"]])

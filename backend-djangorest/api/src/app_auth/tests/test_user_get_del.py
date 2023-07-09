from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import User, InvitationCode
import logging
import core.tests.utils as test_utils


class UserGetDelTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.user_post_url = reverse('user_post')
        self.user_get_del_url = reverse('user_put_get_del')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        # User data
        self.user_data = {
            "username": "username",
            "email": "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            "inv_code": str(self.inv_code.code),
            'pref_coin_type':
                str(CoinType.objects.create(code='EUR').code),
            'language': 'en'
        }
        self.credentials = {
            "email": "email@test.com",
            "password": "password1@212"
        }
        # User creation
        user = User.objects.create(
            username=self.user_data["username"],
            email=self.user_data["email"],
            inv_code=self.inv_code,
            verified=True
        )
        user.set_password(self.user_data['password'])
        user.save()
        # Authenticate
        test_utils.authenticate_user(self.client, self.credentials)
        return super().setUp()

    def test_get_user_data(self):
        """
        Checks that user data is correct
        """
        response = test_utils.get(self.client, self.user_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user_data2 = {
            "username": self.user_data["username"],
            "email": self.user_data["email"],
            "expected_monthly_balance": 0,
            "expected_annual_balance": 0,
        }
        self.assertEqual(response.data["username"], user_data2["username"])
        self.assertEqual(response.data["email"], user_data2["email"])
        self.assertEqual(response.data["expected_monthly_balance"],
                         user_data2["expected_monthly_balance"])
        self.assertEqual(response.data["expected_annual_balance"],
                         user_data2["expected_annual_balance"])

    def test_delete_user(self):
        """
        Checks that user gets deleted
        """
        response = test_utils.delete(self.client, self.user_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

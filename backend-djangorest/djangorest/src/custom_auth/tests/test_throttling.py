from time import time
from unittest import mock
from rest_framework.test import APITestCase
from django.core.cache import cache
from custom_auth.models import User, InvitationCode
from coin.models import CoinType
import core.tests.utils as test_utils

start_time = time()


class ThrottlingTests(APITestCase):

    def setUp(self):
        # Throttling is stored in cache
        cache.clear()
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
        return super().setUp()

    @mock.patch("time.time")
    def test_jwt_access_throttling(self, mock_time):
        """
        Checks that jwt access endpoint has a throttle limit of 50 reuest per minute
        """
        expected_throttle_limit = 50
        mock_time.return_value = start_time
        for _ in range(expected_throttle_limit):
            resp = test_utils.access_token(self.client, self.credentials)
            self.assertEqual(resp.status_code, 200)

        resp = test_utils.access_token(self.client, self.credentials)
        self.assertEqual(resp.status_code, 429)

        mock_time.return_value = start_time + 59

        resp = test_utils.access_token(self.client, self.credentials)
        self.assertEqual(resp.status_code, 429)

        mock_time.return_value = start_time + 60 + 59

        resp = test_utils.access_token(self.client, self.credentials)
        self.assertEqual(resp.status_code, 200)

    @mock.patch("time.time")
    def test_jwt_refresh_throttling(self, mock_time):
        """
        Checks that jwt refresh endpoint has a throttle limit of 100 reuest per minute
        """
        expected_throttle_limit = 100
        mock_time.return_value = start_time
        refresh_token = test_utils.get_refresh_token(self.client, self.credentials)
        for _ in range(expected_throttle_limit):
            resp = test_utils.refresh_token(self.client, refresh_token)
            self.assertEqual(resp.status_code, 200)

        resp = test_utils.refresh_token(self.client, refresh_token)
        self.assertEqual(resp.status_code, 429)

        mock_time.return_value = start_time + 59

        resp = test_utils.refresh_token(self.client, refresh_token)
        self.assertEqual(resp.status_code, 429)

        mock_time.return_value = start_time + 60 + 59

        resp = test_utils.refresh_token(self.client, refresh_token)
        self.assertEqual(resp.status_code, 200)

from django.utils.timezone import now
from rest_framework.test import APITestCase
from coin.models import CoinType
from custom_auth.models import User
from django.utils.translation import gettext_lazy as _

class BalanceModelTests(APITestCase):
    def setUp(self):
        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212"
        }
        return super().setUp()
    
    def create_user(self):
        user = User.objects.create_user(**self.user_data)
        user.set_password(self.user_data['password'])
        user.save()
        return user


    def test_creates_coin_type(self):
        """
        Checks if coin_type is created
        """
        coin_type = CoinType.objects.create(code="EUR")
        self.assertEqual(coin_type.code, "EUR")
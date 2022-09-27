from datetime import date
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
        self.coin_type = CoinType.objects.create(code="EUR")
        return super().setUp()
    
    def create_user(self):
        user = User.objects.create_user(**self.user_data)
        user.set_password(self.user_data['password'])
        user.save()
        return user


    """
    Checks if coin_type is created
    """
    def test_creates_coin_type(self):
        coin_type = self.coin_type
        self.assertEqual(coin_type.code, self.coin_type_data["code"])
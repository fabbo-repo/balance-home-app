from datetime import date
from rest_framework.test import APITestCase
from balance.models import Balance, CoinType
from custom_auth.models import User
from django.utils.translation import gettext_lazy as _

class UserTests(APITestCase):
    def setUp(self):
        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212"
        }
        self.coint_type_data={
            'simb':"EUR",
            'name':"euro"
        }
        return super().setUp()
    
    def create_user(self):
        user = User.objects.create_user(**self.user_data)
        user.set_password(self.user_data['password'])
        user.save()
        return user
    
    def create_coin_type(self):
        coin_type = CoinType.objects.create(**self.coint_type_data)
        coin_type.save()
        return coin_type


    """
    Checks if coin_type is created
    """
    def test_creates_coin_type(self):
        coin_type = self.create_coin_type()
        self.assertEqual(coin_type.simb, self.coint_type_data["simb"])
        self.assertEqual(coin_type.name, self.coint_type_data["name"])
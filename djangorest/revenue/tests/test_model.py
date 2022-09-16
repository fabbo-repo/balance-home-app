from datetime import date
from rest_framework.test import APITestCase
from balance.models import CoinType
from revenue.models import Revenue, RevenueType
from custom_auth.models import InvitationCode, User
from django.utils.translation import gettext_lazy as _

class RevenueModelTests(APITestCase):
    def setUp(self):
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.inv_code.save()
        self.user_data={
            'username':"username1",
            'email':"email1@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code)
        }
        self.rev_type_data={'name':"test"}
        return super().setUp()
    
    def get_revenue_data(self):
        coin_type = CoinType.objects.create(simb='EUR', name='euro')
        coin_type.save()
        return {
            'name': 'Test name',
            'description': 'Test description',
            'quantity': 2.0,
            'coin_type': coin_type,
            'rev_type': self.create_rev_type(),
            'date': date.today(),
            'owner': self.create_user()
        }
    
    def create_user(self):
        user = User.objects.create(
            username=self.user_data['username'],
            email=self.user_data['email'],
            inv_code=self.inv_code
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user
    
    def create_rev_type(self):
        rev_type = RevenueType.objects.create(**self.rev_type_data)
        rev_type.save()
        return rev_type


    """
    Checks if rev_type is created
    """
    def test_creates_rev_type(self):
        rev_type = self.create_rev_type()
        self.assertEqual(rev_type.name, self.rev_type_data["name"])

    """
    Checks if revenue is created
    """
    def test_creates_rev_type(self):
        data = self.get_revenue_data()
        revenue = Revenue.objects.create(**data)
        self.assertEqual(revenue.name, data["name"])
        self.assertEqual(revenue.description, data["description"])
        self.assertEqual(revenue.quantity, data["quantity"])
        self.assertEqual(revenue.coin_type, data["coin_type"])
        self.assertEqual(revenue.rev_type, data["rev_type"])
        self.assertEqual(revenue.date, data["date"])
        self.assertEqual(revenue.owner, data["owner"])
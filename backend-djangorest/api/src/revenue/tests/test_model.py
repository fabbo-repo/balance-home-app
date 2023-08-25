from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from rest_framework.test import APITestCase
from coin.models import CoinType
from revenue.models import Revenue, RevenueType
from app_auth.models import InvitationCode, User
from keycloak_client.django_client import get_keycloak_client


class RevenueModelTests(APITestCase):
    def setUp(self):
        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        # Create CoinType
        self.currency_type = CoinType.objects.create(code="EUR")
        # Test user data
        self.user_data = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": "username1",
            "email": "email1@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
            "pref_currency_type": str(self.currency_type.code),
        }
        self.rev_type = RevenueType.objects.create(name="test")
        return super().setUp()

    def get_revenue_data(self):
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "currency_type": self.currency_type,
            "rev_type": self.rev_type,
            "date": now().date(),
            "owner": self.create_user(),
        }

    def create_user(self):
        return User.objects.create(
            keycloak_id=self.user_data["keycloak_id"],
            inv_code=self.inv_code,
            pref_currency_type=self.currency_type,
        )

    def test_creates_rev_type(self):
        """
        Checks if rev_type is created
        """
        rev_type = RevenueType.objects.create(name="test2")
        self.assertEqual(rev_type.name, "test2")

    def test_creates_rev_type(self):
        """
        Checks if revenue is created
        """
        data = self.get_revenue_data()
        data["converted_quantity"] = 2.0
        revenue = Revenue.objects.create(**data)
        self.assertEqual(revenue.name, data["name"])
        self.assertEqual(revenue.description, data["description"])
        self.assertEqual(revenue.real_quantity, data["real_quantity"])
        self.assertEqual(revenue.converted_quantity, data["converted_quantity"])
        self.assertEqual(revenue.currency_type, data["currency_type"])
        self.assertEqual(revenue.rev_type, data["rev_type"])
        self.assertEqual(revenue.date, data["date"])
        self.assertEqual(revenue.owner, data["owner"])

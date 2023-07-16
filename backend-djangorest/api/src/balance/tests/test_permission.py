from django.utils.timezone import now
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from balance.models import AnnualBalance, CoinType, MonthlyBalance
from app_auth.models import InvitationCode, User
import logging
import core.tests.utils as test_utils


class DateBalancePermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.annual_balance_list = reverse("annual-balance-list")
        self.monthly_balance_list = reverse("monthly-balance-list")

        # Create InvitationCodes
        self.inv_code1 = InvitationCode.objects.create()
        self.inv_code2 = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code="EUR")
        # Test user data
        self.user_data1 = {
            "username": "username1",
            "email": "email1@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code1.code)
        }
        self.user_data2 = {
            "username": "username2",
            "email": "email2@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code2.code)
        }
        self.credentials1 = {
            "email": "email1@test.com",
            "password": "password1@212"
        }
        self.credentials2 = {
            "email": "email2@test.com",
            "password": "password1@212"
        }
        # User creation
        self.user1 = User.objects.create(
            username=self.user_data1["username"],
            email=self.user_data1["email"],
            inv_code=self.inv_code1,
            verified=True
        )
        self.user1.set_password(self.user_data1["password"])
        self.user1.save()
        self.user2 = User.objects.create(
            username=self.user_data2["username"],
            email=self.user_data2["email"],
            inv_code=self.inv_code2,
            verified=True
        )
        self.user2.set_password(self.user_data2["password"])
        self.user2.save()
        return super().setUp()

    def get_annual_balance_data(self, user):
        return {
            "gross_quantity": 1.1,
            "expected_quantity": 2.2,
            "coin_type": self.coin_type,
            "owner": user,
            "year": now().date().year
        }

    def get_monthly_balance_data(self, user):
        return {
            "gross_quantity": 1.1,
            "expected_quantity": 2.2,
            "coin_type": self.coin_type,
            "owner": user,
            "year": now().date().year,
            "month": now().date().month
        }

    def add_annual_balance(self, user):
        data = self.get_annual_balance_data(user)
        return AnnualBalance.objects.create(
            gross_quantity=data["gross_quantity"],
            expected_quantity=data["expected_quantity"],
            coin_type=data["coin_type"],
            owner=data["owner"],
            year=data["year"],
        ).id

    def add_monthly_balance(self, user):
        data = self.get_monthly_balance_data(user)
        return MonthlyBalance.objects.create(
            gross_quantity=data["gross_quantity"],
            expected_quantity=data["expected_quantity"],
            coin_type=data["coin_type"],
            owner=data["owner"],
            year=data["year"],
            month=data["month"]
        ).id

    def test_annual_balance_get_list_url(self):
        """
        Checks permissions with AnnualBalance get and list
        """
        test_utils.authenticate_user(self.client, self.credentials1)
        # Add new AnnualBalance as user1
        id = self.add_annual_balance(self.user1)
        # Get AnnualBalance data as user1
        response = test_utils.get(self.client, self.annual_balance_list)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 1)
        # Get AnnualBalance data as user2
        test_utils.authenticate_user(self.client, self.credentials2)
        response = test_utils.get(self.client, self.annual_balance_list)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 0)
        # Try with an specific expense
        response = test_utils.get(
            self.client, self.annual_balance_list+"/"+str(id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_monthly_balance_get_list_url(self):
        """
        Checks permissions with MonthlyBalance get and list
        """
        test_utils.authenticate_user(self.client, self.credentials1)
        # Add new MonthlyBalance as user1
        id = self.add_monthly_balance(self.user1)
        # Get MonthlyBalance data as user1
        response = test_utils.get(self.client, self.monthly_balance_list)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 1)
        # Get MonthlyBalance data as user2
        test_utils.authenticate_user(self.client, self.credentials2)
        response = test_utils.get(self.client, self.monthly_balance_list)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 0)
        # Try with an specific expense
        response = test_utils.get(
            self.client, self.monthly_balance_list+"/"+str(id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

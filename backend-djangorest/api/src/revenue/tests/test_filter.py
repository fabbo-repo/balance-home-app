from django.utils.timezone import now, timedelta
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import InvitationCode, User
import logging
from revenue.models import RevenueType
from rest_framework import status
import core.tests.utils as test_utils


class RevenueFilterTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.revenue_url=reverse("revenue-list")
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.currency_type = CoinType.objects.create(code="EUR")
        self.user_data={
            "username":"username",
            "email":"email@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
            "pref_currency_type": str(self.currency_type.code)
        }
        self.credentials = {
            "email":"email@test.com",
            "password": "password1@212"
        }
        self.user = self.create_user()
        self.rev_type = RevenueType.objects.create(name="test")
        return super().setUp()
    
    def get_revenue_data(self):
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.6,
            "currency_type": self.currency_type.code,
            "rev_type": self.rev_type.name,
            "date": str(now().date()),
            "owner": str(self.user),
        }
    
    def create_user(self):
        user = User.objects.create(
            username=self.user_data["username"],
            email=self.user_data["email"],
            inv_code=self.inv_code,
            verified=True,
            pref_currency_type=self.currency_type,
        )
        user.set_password(self.user_data["password"])
        user.save()
        return user

    def authenticate_add_revenue(self):
        test_utils.authenticate_user(self.client, self.credentials)
        data = self.get_revenue_data()
        # Add new revenue
        test_utils.post(self.client, self.revenue_url, data)
    

    def test_revenue_filter_date(self):
        """
        Checks Revenue filter by date
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+"?date="+str(now().date())
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)
        
    def test_revenue_filter_date_from_to(self):
        """
        Checks Revenue filter by date form to
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+"?date_from=" \
            +str(
                now().date() - timedelta(days=1)
            )+"&date_to=" \
            +str(
                now().date() + timedelta(days=1)
            )
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)
    
    def test_revenue_filter_rev_type(self):
        """
        Checks Revenue filter by rev_type
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+"?rev_type=test"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)

    def test_revenue_filter_currency_type(self):
        """
        Checks Revenue filter by currency_type
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+"?currency_type=EUR"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)
    
    def test_revenue_filter_quantity_min_and_max(self):
        """
        Checks Revenue filter by quantity min and max
        """
        self.authenticate_add_revenue()
        # Get revenue data
        url = self.revenue_url+"?converted_quantity_min=1.0&converted_quantity_max=3.0"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 1)
        # Get revenue data
        url = self.revenue_url+"?converted_quantity_min=6.0&converted_quantity_max=8.0"
        response = test_utils.get(self.client, url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = dict(response.data)
        self.assertEqual(data["count"], 0)
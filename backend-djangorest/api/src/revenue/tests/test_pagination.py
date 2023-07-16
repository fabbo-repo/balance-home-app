from django.utils.timezone import now
from rest_framework.test import APITestCase
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import InvitationCode, User
import logging
from revenue.models import RevenueType
import core.tests.utils as test_utils


class RevenuePaginationTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.revenue_url = reverse("revenue-list")
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code="EUR")
        self.user_data = {
            "username": "username",
            "email": "email@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
        }
        self.credentials = {
            "email": "email@test.com",
            "password": "password1@212"
        }
        self.user = self.create_user()
        self.rev_type = RevenueType.objects.create(name="test")
        return super().setUp()

    def get_revenue_data(self):
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "coin_type": self.coin_type.code,
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
            pref_currency_type=self.coin_type,
        )
        user.set_password(self.user_data["password"])
        user.save()
        return user

    def test_revenue_pagination_scheme(self):
        """
        Checks Revenue pagination scheme is correct
        """
        data = self.get_revenue_data()
        # Add new revenue
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.revenue_url, data)
        # Get revenue data
        response = test_utils.get(self.client, self.revenue_url)
        scheme = dict(response.data)
        scheme["results"] = []
        results = dict(response.data)["results"]

        for result in results:
            result = dict(result)
            result["rev_type"] = dict(result["rev_type"])
            scheme["results"] += [result]
        expected_scheme = {
            "count": 1, "next": None, "previous": None,
            "results": [
                {
                    "id": 1,
                    "name": "Test name",
                    "description": "Test description",
                    "real_quantity": 2.0,
                    "converted_quantity": 2.0,
                    "date": str(now().date()),
                    "coin_type": "EUR",
                    "rev_type": {
                        "name": "test",
                        "image": "http://testserver/media/core/default_image.jpg"
                    }
                }
            ]
        }
        self.assertEqual(scheme, expected_scheme)

    def test_revenue_two_pages(self):
        """
        Checks 2 pages of Revenue data is correct
        """
        test_utils.authenticate_user(self.client, self.credentials)
        for i in range(20):
            data = self.get_revenue_data()
            # Add new revenue
            test_utils.post(self.client, self.revenue_url, data)
        # Get First page revenue data
        response = test_utils.get(self.client, self.revenue_url)
        data = dict(response.data)
        self.assertEqual(data["count"], 20)
        # 10 revenues in the first page
        self.assertEqual(len(data["results"]), 10)
        # Second page
        response = test_utils.get(self.client, data["next"])
        self.assertEqual(data["count"], 20)
        # 10 revenues in the first page
        self.assertEqual(len(data["results"]), 10)

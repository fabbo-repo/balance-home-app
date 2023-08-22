import logging
import core.tests.utils as test_utils
from django.utils.timezone import now
from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from coin.models import CoinType
from app_auth.models import InvitationCode, User
from revenue.models import Revenue, RevenueType
from keycloak_client.django_client import get_keycloak_client


class RevenueUrlsPermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.revenue_url = reverse("revenue-list")
        self.rev_type_list_url = reverse("rev_type_list")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )
        # Create CoinTypes
        self.currency_type = CoinType.objects.create(  # pylint: disable=no-member
            code="EUR"
        )
        # Test user data
        # Test user data
        self.user_data1 = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id,
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale,
            "pref_currency_type": str(self.currency_type.code),
        }
        self.user_data2 = {
            "keycloak_id": self.keycloak_client_mock.keycloak_id + "1",
            "username": "username2",
            "email": "email2@test.com",
            "password": "password1@212",
            "inv_code": str(self.inv_code.code),
            "locale": "en",
            "pref_currency_type": str(self.currency_type.code),
        }
        # User creation
        User.objects.create(
            keycloak_id=self.user_data1["keycloak_id"],
            pref_currency_type=self.currency_type,
            inv_code=self.inv_code,
        )
        User.objects.create(
            keycloak_id=self.user_data2["keycloak_id"],
            pref_currency_type=self.currency_type,
            inv_code=self.inv_code,
        )
        return super().setUp()

    def get_revenue_type_data(self):
        rev_type = RevenueType.objects.create(name="test")
        return {"name": rev_type.name, "image": rev_type.image}

    def get_revenue_data(self):
        rev_type = self.get_revenue_type_data()
        return {
            "name": "Test name",
            "description": "Test description",
            "real_quantity": 2.0,
            "currency_type": self.currency_type.code,
            "rev_type": rev_type["name"],
            "date": str(now().date()),
        }

    def test_revenue_type_get_list_url(self):
        """
        Checks permissions with Revenue Type get and list
        """
        data = self.get_revenue_type_data()
        # Get revenue type data without authentication
        response = test_utils.get(self.client, self.rev_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with an specific revenue
        response = test_utils.get(
            self.client, self.rev_type_list_url + "/" + str(data["name"])
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get revenue type data with authentication
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        response = test_utils.get(self.client, self.rev_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Try with an specific revenue
        response = test_utils.get(
            self.client, self.rev_type_list_url + "/" + str(data["name"])
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_revenue_post_url(self):
        """
        Checks permissions with Revenue post
        """
        data = self.get_revenue_data()
        # Try without authentication
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with authentication
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Compare owner
        revenue = Revenue.objects.get(name="Test name")
        self.assertEqual(revenue.owner.keycloak_id, self.user_data1["keycloak_id"])

    def test_revenue_get_list_url(self):
        """
        Checks permissions with Revenue get and list
        """
        data = self.get_revenue_data()
        # Add new revenue as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        test_utils.post(self.client, self.revenue_url, data)
        # Get revenue data as user1
        response = test_utils.get(self.client, self.revenue_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 1)
        # Get revenue data as user2
        test_utils.authenticate_user(self.client, self.user_data2["keycloak_id"])
        response = test_utils.get(self.client, self.revenue_url)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)["count"], 0)
        # Try with an specific revenue
        revenue = Revenue.objects.get(name="Test name")
        response = test_utils.get(self.client, self.revenue_url + "/" + str(revenue.id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_revenue_put_url(self):
        """
        Checks permissions with Revenue patch (almost same as put)
        """
        data = self.get_revenue_data()
        # Add new revenue as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        test_utils.post(self.client, self.revenue_url, data)
        revenue = Revenue.objects.get(name="Test name")
        # Try update as user1
        response = test_utils.patch(
            self.client,
            self.revenue_url + "/" + str(revenue.id),
            {"real_quantity": 35.0},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check revenue
        revenue = Revenue.objects.get(name="Test name")
        self.assertEqual(revenue.real_quantity, 35.0)
        # Try update as user2
        test_utils.authenticate_user(self.client, self.user_data2["keycloak_id"])
        response = test_utils.patch(
            self.client,
            self.revenue_url + "/" + str(revenue.id),
            {"real_quantity": 30.0},
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_revenue_delete_url(self):
        """
        Checks permissions with Revenue delete
        """
        data = self.get_revenue_data()
        # Add new revenue as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        test_utils.post(self.client, self.revenue_url, data)
        # Delete revenue data as user2
        test_utils.authenticate_user(self.client, self.user_data2["keycloak_id"])
        revenue = Revenue.objects.get(name="Test name")
        response = test_utils.delete(
            self.client, self.revenue_url + "/" + str(revenue.id)
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        # Delete revenue data as user1
        test_utils.authenticate_user(self.client, self.user_data1["keycloak_id"])
        response = test_utils.delete(
            self.client, self.revenue_url + "/" + str(revenue.id)
        )
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

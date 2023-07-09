from django.utils.timezone import now
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import InvitationCode, User
import logging
from revenue.models import Revenue, RevenueType
import core.tests.utils as test_utils


class RevenueLogicTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.revenue_url = reverse('revenue-list')
        # Create InvitationCodes
        self.inv_code = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code='EUR')
        self.user_data = {
            'username': "username",
            'email': "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
            'pref_coin_type': str(self.coin_type.code)
        }
        self.credentials = {
            'email': "email@test.com",
            "password": "password1@212"
        }
        self.user = self.create_user()
        self.rev_type = RevenueType.objects.create(name="test")

    def get_revenue_data(self):
        return {
            'name': 'Test name',
            'description': '',
            'real_quantity': 2.0,
            'coin_type': self.coin_type.code,
            'rev_type': self.rev_type.name,
            'date': str(now().date()),
            'owner': str(self.user),
        }

    def create_user(self):
        user = User.objects.create(
            username=self.user_data['username'],
            email=self.user_data['email'],
            inv_code=self.inv_code,
            verified=True,
            balance=1,
            pref_coin_type=self.coin_type,
        )
        user.set_password(self.user_data['password'])
        user.save()
        return user

    def authenticate_add_revenue(self):
        test_utils.authenticate_user(self.client, self.credentials)
        data = self.get_revenue_data()
        # Add new revenue
        test_utils.post(self.client, self.revenue_url, data)

    def test_revenue_post(self):
        """
        Checks balance gets updated with Revenue post
        """
        data = self.get_revenue_data()
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.revenue_url, data)
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 3)
        # Negative quantity not allowed
        data['real_quantity'] = -10.0
        response = test_utils.post(self.client, self.revenue_url, data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('real_quantity', [field["name"]
                      for field in response.data["fields"]])

    def test_revenue_patch(self):
        """
        Checks balance gets updated with Revenue patch (similar to put)
        """
        data = self.get_revenue_data()
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.revenue_url, data)
        revenue = Revenue.objects.get(name='Test name')
        # Patch method
        test_utils.patch(self.client, self.revenue_url+'/' +
                         str(revenue.id), {'real_quantity': 35.0})
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 36)

    def test_revenue_delete_url(self):
        """
        Checks balance gets updated with Revenue delete
        """
        data = self.get_revenue_data()
        test_utils.authenticate_user(self.client, self.credentials)
        test_utils.post(self.client, self.revenue_url, data)
        data2 = data
        data2['name'] = 'test'
        test_utils.post(self.client, self.revenue_url, data2)
        revenue = Revenue.objects.get(name='Test name')
        # Delete method
        test_utils.delete(self.client, self.revenue_url+'/'+str(revenue.id))
        user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(user.balance, 3)

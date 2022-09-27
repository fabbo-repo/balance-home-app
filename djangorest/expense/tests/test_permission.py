from datetime import date
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from expense.models import Expense, ExpenseType


class ExpensePermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.expense_url=reverse('expense-list')
        self.exp_type_list_url=reverse('exp_type_list')
        
        # Create InvitationCodes
        self.inv_code1 = InvitationCode.objects.create()
        self.inv_code2 = InvitationCode.objects.create()
        # Test user data
        self.user_data1={
            'username':"username1",
            'email':"email1@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code1.code)
        }
        self.user_data2={
            'username':"username2",
            'email':"email2@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code2.code)
        }
        self.credentials1 = {
            'email':"email1@test.com",
            "password": "password1@212"
        }
        self.credentials2 = {
            'email':"email2@test.com",
            "password": "password1@212"
        }
        self.coin_type = CoinType.objects.create(code='EUR')
        # User creation
        user1 = User.objects.create(
            username=self.user_data1["username"],
            email=self.user_data1["email"],
            inv_code=self.inv_code1,
            verified=True,
            pref_coin_type=self.coin_type
        )
        user1.set_password(self.user_data1['password'])
        user1.save()
        user2 = User.objects.create(
            username=self.user_data2["username"],
            email=self.user_data2["email"],
            inv_code=self.inv_code2,
            verified=True,
            pref_coin_type=self.coin_type
        )
        user2.set_password(self.user_data2['password'])
        user2.save()
        return super().setUp()
    
    def get(self, url) :
        return self.client.get(url)
    
    def post(self, url, data={}) :
        return self.client.post(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def patch(self, url, data={}) :
        return self.client.patch(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def delete(self, url) :
        return self.client.delete(url)
    
    def authenticate_user(self, credentials):
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
    
    def get_expense_type_data(self):
        exp_type = ExpenseType.objects.create(name='test')
        return {
            'name': exp_type.name,
            'image': exp_type.image
        }
    
    def get_expense_data(self):
        exp_type = ExpenseType.objects.create(name='test')
        return {
            'name': 'Test name',
            'description': 'Test description',
            'quantity': 2.0,
            'coin_type': self.coin_type.code,
            'exp_type': exp_type.name,
            'date': str(date.today())
        }


    """
    Checks permissions with Expense Type get and list
    """
    def test_expense_type_get_list_url(self):
        data = self.get_expense_type_data()
        # Get expense type data without authentication
        response = self.get(self.exp_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with an specific expense
        response = self.get(self.exp_type_list_url+'/'+str(data['name']))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get expense type data with authentication
        self.authenticate_user(self.credentials1)
        response = self.get(self.exp_type_list_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Try with an specific expense
        response = self.get(self.exp_type_list_url+'/'+str(data['name']))
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    """
    Checks permissions with Expense post
    """
    def test_expense_post_url(self):
        data = self.get_expense_data()
        # Try without authentication
        response=self.post(self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Try with authentication
        self.authenticate_user(self.credentials1)
        response=self.post(self.expense_url, data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Compare owner
        expense = Expense.objects.get(name="Test name")
        self.assertEqual(expense.owner.email, self.user_data1['email'])

    """
    Checks permissions with Expense get and list
    """
    def test_expense_get_list_url(self):
        data = self.get_expense_data()
        # Add new expense as user1
        self.authenticate_user(self.credentials1)
        self.post(self.expense_url, data)
        # Get expense data as user1
        response = self.get(self.expense_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 1)
        # Get expense data as user2
        self.authenticate_user(self.credentials2)
        response = self.get(self.expense_url)
        # Gets an empty dict
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(dict(response.data)['count'], 0)
        # Try with an specific expense
        expense = Expense.objects.get(name='Test name')
        response = self.get(self.expense_url+'/'+str(expense.id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    """
    Checks permissions with Expense patch (almost same as put)
    """
    def test_expense_put_url(self):
        data = self.get_expense_data()
        # Add new expense as user1
        self.authenticate_user(self.credentials1)
        self.post(self.expense_url, data)
        expense = Expense.objects.get(name='Test name')
        # Try update as user1
        response=self.patch(self.expense_url+'/'+str(expense.id), {'quantity': 35.0})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check expense
        expense = Expense.objects.get(name='Test name')
        self.assertEqual(expense.quantity, 35.0)
        # Try update as user2
        self.authenticate_user(self.credentials2)
        response=self.patch(self.expense_url+'/'+str(expense.id), {'quantity': 30.0})
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    """
    Checks permissions with Expense delete
    """
    def test_expense_delete_url(self):
        data = self.get_expense_data()
        # Add new expense as user1
        self.authenticate_user(self.credentials1)
        self.post(self.expense_url, data)
        # Delete expense data as user2
        self.authenticate_user(self.credentials2)
        expense = Expense.objects.get(name='Test name')
        response = self.delete(self.expense_url+'/'+str(expense.id))
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        # Delete expense data as user1
        self.authenticate_user(self.credentials1)
        response = self.delete(self.expense_url+'/'+str(expense.id))
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
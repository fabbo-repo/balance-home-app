from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinExchange, CoinType
from custom_auth.models import User, InvitationCode
import logging
import json
from expense.models import Expense, ExpenseType
from coin.currency_converter_integration import (
    NoCoinExchangeException, 
    OldExchangeException, 
    UnsupportedExchangeException, 
    _convert, update_exchange_data
)
from revenue.models import Revenue, RevenueType
from django.utils.timezone import now, timedelta


class ExchangeLogicTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.revenue_url=reverse('revenue-list')
        self.expense_url=reverse('expense-list')
        self.user_put_get_del_url=reverse('user_put_get_del')
        
        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        # Create CoinTypes
        self.coin_type1 = CoinType.objects.create(code='EUR')
        self.coin_type2 = CoinType.objects.create(code='USD')
        self.coin_type3 = CoinType.objects.create(code='CAD')
        # Test user data
        self.user_data={
            'username':"username1",
            'email':"email1@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'verified': True,
            'balance': 10.0,
            'inv_code': str(self.inv_code.code),
            'pref_coin_type': str(self.coin_type1.code),
            'language': 'en'
        }
        self.credentials = {
            'email':"email1@test.com",
            "password": "password1@212"
        }
        # User creation
        user = User.objects.create(
            username=self.user_data["username"],
            email=self.user_data["email"],
            inv_code=self.inv_code,
            balance=self.user_data["balance"],
            verified=True,
            pref_coin_type=self.coin_type1,
            language='en'
        )
        user.set_password(self.user_data['password'])
        user.save()
        # Authenticate user
        jwt=self.post(self.jwt_obtain_url, {
            'email':"email1@test.com",
            "password": "password1@212"
        }).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
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
    
    def get_create_revenue_type_data(self, name='test'):
        rev_type, created = RevenueType.objects.get_or_create(name=name)
        return rev_type
    
    def get_revenue_data(self, coin_type):
        rev_type = self.get_create_revenue_type_data()
        owner = User.objects.get(email=self.user_data['email'])
        return {
            'name': 'Test name',
            'description': 'Test description',
            'real_quantity': 1.0,
            'coin_type': coin_type.code,
            'rev_type': rev_type.name,
            'date': str(now().date()),
            'owner': owner,
            'owner': str(owner.id)
        }
    
    def get_create_revenue(self, coin_type):
        rev_type = self.get_create_revenue_type_data()
        owner = User.objects.get(email=self.user_data['email'])
        return Revenue.objects.create(
            name='Test name',
            description='Test description',
            real_quantity=1.0,
            converted_quantity=1.0,
            coin_type=coin_type,
            rev_type=rev_type,
            date=now(),
            owner=owner
        )
    
    def get_create_expense_type_data(self, name='test'):
        exp_type, created = ExpenseType.objects.get_or_create(name=name)
        return exp_type
    
    def get_expense_data(self, coin_type):
        exp_type = self.get_create_expense_type_data()
        owner = User.objects.get(email=self.user_data['email'])
        return {
            'name': 'Test name',
            'description': 'Test description',
            'real_quantity': 1.0,
            'coin_type': coin_type.code,
            'exp_type': exp_type.name,
            'date': str(now().date()),
            'owner': str(owner.id)
        }
    
    def get_create_expense(self, coin_type):
        exp_type = self.get_create_expense_type_data()
        owner = User.objects.get(email=self.user_data['email'])
        return Expense.objects.create(
            name='Test name',
            description='Test description',
            real_quantity=1.0,
            converted_quantity=1.0,
            coin_type=coin_type,
            exp_type=exp_type,
            date=now(),
            owner=owner
        )


    def test_currency_converter_service(self):
        """
        Checks if currency converter service works
        """
        try:
            update_exchange_data()
            CoinExchange.objects.get(created__date=now().date())
            self.assertTrue(True)
        except:
            self.assertTrue(False)
    
    def test_currency_converter_service_no_coin_exception(self):
        """
        Checks if currency converter service raise `NoCoinExchangeException`
        """
        self.assertRaises(
            NoCoinExchangeException,
            _convert,
            self.coin_type1,
            self.coin_type2,
            2
        )
    
    def test_currency_converter_service_old_exception(self):
        """
        Checks if currency converter service raise `OldExchangeException`
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        coin_exchange = CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        coin_exchange.created = now() - timedelta(days=2)
        coin_exchange.save()
        self.assertRaises(
            OldExchangeException,
            _convert,
            self.coin_type1,
            self.coin_type2,
            2
        )

    def test_currency_converter_service_old_exception(self):
        """
        Checks if currency converter service raise `OldExchangeException`
        """
        exchange = {}
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        self.assertRaises(
            UnsupportedExchangeException,
            _convert,
            self.coin_type1,
            self.coin_type2,
            2
        )

    def test_post_revenue_diff_coin_type(self):
        """
        Check `posting` an revenue with coin type different 
        from the user's prefered coin type results in a conversion
        of the revenue quantity
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        rev_data = self.get_revenue_data(self.coin_type2)
        resp = self.post(self.revenue_url, rev_data)
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            User.objects.get(email=self.user_data['email']).balance,
            self.user_data['balance'] + (rev_data['real_quantity'] * 1.3)
        )
    
    def test_post_expense_diff_coin_type(self):
        """
        Check `posting` an expense with coin type different 
        from the user's prefered coin type results in a conversion
        of the expense quantity
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        exp_data = self.get_expense_data(self.coin_type2)
        resp = self.post(self.expense_url, exp_data)
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(
            User.objects.get(email=self.user_data['email']).balance,
            self.user_data['balance'] - (exp_data['real_quantity'] * 1.3)
        )
    
    def test_patch_revenue_diff_coin_type(self):
        """
        Check `patching` an revenue with coin type different 
        from the user's prefered coin type to a another different
        `coin_type` results in an extra conversion of the revenue 
        quantity
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        rev = self.get_create_revenue(self.coin_type2)
        resp = self.patch(self.revenue_url+'/'+str(rev.id), {
            'real_quantity': 2,
            'coin_type': self.coin_type3.code
        })
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(
            User.objects.get(email=self.user_data['email']).balance,
            round(
                self.user_data['balance'] + (2 * 0.8) - (rev.converted_quantity * 1.3), 
                2
            )
        )

    def test_patch_expense_diff_coin_type(self):
        """
        Check `patching` an expense with coin type different 
        from the user's prefered coin type to a another different
        `coin_type` results in an extra conversion of the expense 
        quantity
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        exp = self.get_create_expense(self.coin_type2)
        resp = self.patch(self.expense_url+'/'+str(exp.id), {
            'real_quantity': 2,
            'coin_type': self.coin_type3.code
        })
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(
            User.objects.get(email=self.user_data['email']).balance,
            round(
                self.user_data['balance'] - ((2 * 0.8) - (exp.converted_quantity * 1.3)), 
                2
            )
        )
    
    def test_delete_revenue_diff_coin_type(self):
        """
        Check `deleting` an revenue with coin type different 
        from the user's prefered `coin_type` results in a 
        conversion of the revenue quantity
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        rev = self.get_create_revenue(self.coin_type2)
        resp = self.delete(self.revenue_url+'/'+str(rev.id))
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(
            User.objects.get(email=self.user_data['email']).balance,
            round(
                self.user_data['balance'] - (rev.converted_quantity * 1.3), 
                2
            )
        )

    def test_delete_expense_diff_coin_type(self):
        """
        Check `deleting` an expense with coin type different 
        from the user's prefered `coin_type` results in a 
        conversion of the expense quantity
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        exp = self.get_create_expense(self.coin_type2)
        resp = self.delete(self.expense_url+'/'+str(exp.id))
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(
            User.objects.get(email=self.user_data['email']).balance,
            round(
                self.user_data['balance'] + (exp.converted_quantity * 1.3), 
                2
            )
        )
    
    def test_user_pref_coin_type(self):
        """
        Check changing user's `pref_coin_type` should convert
        user's balance
        """
        exchange = {
            'EUR' : { 'USD': 0.8, 'CAD': 1.2 },
            'USD' : { 'CAD': 1.5, 'EUR': 1.3 },
            'CAD' : { 'USD': 0.6, 'EUR': 0.8 },
        }
        CoinExchange.objects.create(
            exchange_data = json.dumps(exchange)
        )
        resp = self.patch(self.user_put_get_del_url,
            {
                'balance': self.user_data['balance'],
                'pref_coin_type': self.coin_type2.code
            }
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        updated_user = User.objects.get(email=self.user_data['email'])
        self.assertEqual(updated_user.pref_coin_type, self.coin_type2)
        self.assertEqual(
            updated_user.balance,
            round(
                self.user_data['balance'] * 0.8, 
                2
            )
        )
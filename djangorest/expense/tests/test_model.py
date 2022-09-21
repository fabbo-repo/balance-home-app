from datetime import date
from rest_framework.test import APITestCase
from balance.models import CoinType
from expense.models import Expense, ExpenseType
from custom_auth.models import InvitationCode, User
from django.utils.translation import gettext_lazy as _

class ExpenseModelTests(APITestCase):
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
        self.exp_type_data={'name':"test"}
        return super().setUp()
    
    def get_expense_data(self):
        coin_type = CoinType.objects.create(code='EUR', name='euro')
        coin_type.save()
        return {
            'name': 'Test name',
            'description': 'Test description',
            'quantity': 2.0,
            'coin_type': coin_type,
            'exp_type': self.create_exp_type(),
            'date': str(date.today()),
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
    
    def create_exp_type(self):
        exp_type = ExpenseType.objects.create(**self.exp_type_data)
        exp_type.save()
        return exp_type


    """
    Checks if exp_type is created
    """
    def test_creates_exp_type(self):
        exp_type = self.create_exp_type()
        self.assertEqual(exp_type.name, self.exp_type_data["name"])

    """
    Checks if expense is created
    """
    def test_creates_exp_type(self):
        data = self.get_expense_data()
        expense = Expense.objects.create(**data)
        self.assertEqual(expense.name, data["name"])
        self.assertEqual(expense.description, data["description"])
        self.assertEqual(expense.quantity, data["quantity"])
        self.assertEqual(expense.coin_type, data["coin_type"])
        self.assertEqual(expense.exp_type, data["exp_type"])
        self.assertEqual(expense.date, data["date"])
        self.assertEqual(expense.owner, data["owner"])
from datetime import date, timedelta
from django.core.mail import send_mail
from django.conf import settings
from celery import shared_task
from balance.models import AnnualBalance, MonthlyBalance
from expense.models import Expense
from revenue.models import Revenue
from custom_auth.models import User
from balance import notifications

import logging
logger = logging.getLogger(__name__)


def _calculate_balance_by_month(user, month, year):
    monthly_revenues = Revenue.objects.filter(
        owner=user, date__month=str(month), date__year=str(year))
    monthly_expenses = Expense.objects.filter(
        owner=user, date__month=str(month), date__year=str(year))
    balance = 0.0
    for revenue in monthly_revenues:
        balance += revenue.quantity
    for expense in monthly_expenses:
        balance -= expense.quantity
    return balance

def _calculate_balance_by_year(user, year):
    annual_revenues = Revenue.objects.filter(
        owner=user, date__year=str(year))
    annual_expenses = Expense.objects.filter(
        owner=user, date__year=str(year))
    balance = 0.0
    for revenue in annual_revenues:
        balance += revenue.quantity
    for expense in annual_expenses:
        balance -= expense.quantity
    return balance

@shared_task
def compute_montly_balance(
        user, month, year,
        is_last=False
    ):
    monthly_balance = _calculate_balance_by_month(user, month, year)
    montly_result = str(user.expected_monthly_balance-monthly_balance)
    try:
        model=MonthlyBalance.objects.get(month=month, year=year)
        if is_last:
            logger.error('Last monthly balance already created with id: '
                +str(model.id)+', skipping')
            return
        model.quantity = monthly_balance
        model.save()
    except:
        if is_last:
            user.last_monthly_balance=monthly_balance
            user.save()
        notifications.send_monthly_balance(
            user.email,
            month,
            year,
            monthly_balance,
            user.expected_monthly_balance,
            montly_result,
            user.language
        )

@shared_task
def compute_annual_balance(
        user, year,
        is_last=False
    ):
    annual_balance = _calculate_balance_by_year(user, year)
    annual_result = str(user.expected_annual_balance-annual_balance)
    try:
        model=AnnualBalance.objects.get(year=year)
        if is_last:
            logger.error('Last annual balance already created with id: '
                +str(model.id)+', skipping')
            return
        model.quantity = annual_balance
        model.save()
    except:
        if is_last:
            user.last_annual_balance = annual_balance
            user.save()
        notifications.send_annual_balance(
            user.email,
            year,
            annual_balance,
            user.expected_annual_balance,
            annual_result,
            user.language
        )


@shared_task
def periodic_monthly_balance():
    yesterday = date.today() - timedelta(days=1)
    month = yesterday.month
    year = yesterday.year
    for user in User.objects:
        if user.verified and user.receive_email_balance:
            compute_montly_balance(user, month, year, True).delay()


@shared_task
def periodic_annual_balance():
    yesterday = date.today() - timedelta(days=1)
    year = yesterday.year
    for user in User.objects:
        if user.verified and user.receive_email_balance:
            compute_annual_balance(user, year, True).delay()
from datetime import date
from django.core.mail import send_mail
from django.conf import settings
from celery import shared_task
from balance.models import AnnualBalance, MonthlyBalance
from expense.models import Expense
from revenue.models import Revenue

import logging
logger = logging.getLogger(__name__)

MONTHS={
    1: "January", 2: "February", 3: "March", 4: "April", 5:"May", 
    6: "June", 7: "July", 8: "August", 9: "September", 
    10: "October", 11: "November", 12: "December"
}

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
    body = MONTHS[month]+" balance: "+str(monthly_balance) \
        +", expected balance: "+str(user.expected_monthly_balance) \
        +". Result: "+str(montly_result)
    try:
        model=MonthlyBalance.objects.get(month=month, year=year)
        if is_last:
            logger.error('Last monthly balance already created with id: '
                +str(model.id)+', skipping')
            return
        model.quantity=monthly_balance
        model.save()
    except:
        if is_last:
            user.last_monthly_balance=monthly_balance
            user.save()
        send_mail(
            'Balance summary', body,
            settings.EMAIL_HOST_USER,
            [user.email], fail_silently=False
        )

@shared_task
def compute_annual_balance(
        user, year,
        is_last=False
    ):
    annual_balance = _calculate_balance_by_year(user, year)
    annual_result = str(user.expected_annual_balance-annual_balance)
    body = str(year)+" balance: "+str(annual_balance) \
        +", expected balance: "+str(user.expected_annual_balance) \
        +". Result: "+str(annual_result)
    try:
        model=AnnualBalance.objects.get(year=year)
        if is_last:
            logger.error('Last annual balance already created with id: '
                +str(model.id)+', skipping')
            return
        model.quantity=annual_balance
        model.save()
    except:
        if is_last:
            user.last_annual_balance=annual_balance
            user.save()
        send_mail(
            'Balance summary', body,
            settings.EMAIL_HOST_USER,
            [user.email], fail_silently=False
        )
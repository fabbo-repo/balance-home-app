import logging
from celery import shared_task
from app_auth.models import User
from balance.models import MonthlyBalance, AnnualBalance
from revenue.models import Revenue
from expense.models import Expense
from coin.models import CoinType
from coin.currency_converter_integration import convert_or_fetch
from django.db import transaction

logger = logging.getLogger(__name__)


@shared_task
def remove_unverified_users():
    try:
        for user in User.objects.all():
            if not user.verified:
                user.delete()
    except Exception as e:
        logger.error("[DEL UNVERIFIED USER TASK] "+str(e))


@shared_task
def change_converted_quantities(owner_email, coin_from_code, coin_to_code):
    coin_from = CoinType.objects.get(code=coin_from_code)
    coin_to = CoinType.objects.get(code=coin_to_code)
    try:
        with transaction.atomic():
            for revenue in Revenue.objects.filter(
                owner=User.objects.get(email=owner_email
                                       )):
                revenue.converted_quantity = convert_or_fetch(
                    coin_from, coin_to,
                    revenue.converted_quantity
                )
                revenue.save()
            for expense in Expense.objects.filter(
                owner=User.objects.get(email=owner_email
                                       )):
                expense.converted_quantity = convert_or_fetch(
                    coin_from, coin_to,
                    expense.converted_quantity
                )
                expense.save()
            for dateBalance in MonthlyBalance.objects.filter(
                owner=User.objects.get(email=owner_email
                                       )):
                dateBalance.gross_quantity = convert_or_fetch(
                    coin_from, coin_to,
                    dateBalance.gross_quantity
                )
                dateBalance.expected_quantity = convert_or_fetch(
                    coin_from, coin_to,
                    dateBalance.expected_quantity
                )
                dateBalance.save()
            for dateBalance in AnnualBalance.objects.filter(
                owner=User.objects.get(email=owner_email
                                       )):
                dateBalance.gross_quantity = convert_or_fetch(
                    coin_from, coin_to,
                    dateBalance.gross_quantity
                )
                dateBalance.expected_quantity = convert_or_fetch(
                    coin_from, coin_to,
                    dateBalance.expected_quantity
                )
                dateBalance.save()
    except Exception as e:
        logger.error("[CHANGE CONVERTED QUANTITIES TASK] "+str(e))

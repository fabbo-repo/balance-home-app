import logging
from celery import shared_task
from app_auth.models import User
from balance.models import MonthlyBalance, AnnualBalance
from revenue.models import Revenue
from expense.models import Expense
from coin.models import CoinType
from coin.currency_converter_integration import convert_or_fetch
from django.db import transaction
from keycloak_client.django_client import get_keycloak_client

logger = logging.getLogger(__name__)


@shared_task
def remove_unverified_users():
    keycloak_client = get_keycloak_client()
    for user in User.objects.all():
        with transaction.atomic():
            user_info = keycloak_client.get_user_info_by_id(
                keycloak_id=user.keycloak_id)
            if not user_info["emailVerified"]:
                user.delete()
                keycloak_client.delete_user_by_id(
                    keycloak_id=user.keycloak_id)


@shared_task
def change_converted_quantities(owner_keycloak_id, coin_from_code, coin_to_code):
    coin_from = CoinType.objects.get(  # pylint: disable=no-member
        code=coin_from_code)
    coin_to = CoinType.objects.get(  # pylint: disable=no-member
        code=coin_to_code)
    with transaction.atomic():
        for revenue in Revenue.objects.filter(  # pylint: disable=no-member
                owner=User.objects.get(
                    keycloak_id=owner_keycloak_id
                )):
            revenue.converted_quantity = convert_or_fetch(
                coin_from, coin_to,
                revenue.converted_quantity
            )
            revenue.save()
        for expense in Expense.objects.filter(  # pylint: disable=no-member
                owner=User.objects.get(
                    keycloak_id=owner_keycloak_id
                )):
            expense.converted_quantity = convert_or_fetch(
                coin_from, coin_to,
                expense.converted_quantity
            )
            expense.save()
        for dateBalance in MonthlyBalance.objects.filter(  # pylint: disable=no-member
                owner=User.objects.get(
                    keycloak_id=owner_keycloak_id
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
        for dateBalance in AnnualBalance.objects.filter(  # pylint: disable=no-member
                owner=User.objects.get(
                    keycloak_id=owner_keycloak_id
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

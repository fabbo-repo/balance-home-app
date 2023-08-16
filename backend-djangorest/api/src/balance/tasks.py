from django.utils.timezone import now, timedelta
from celery import shared_task
from balance.models import AnnualBalance, MonthlyBalance
from coin.currency_converter_integration import convert_or_fetch
from app_auth.models import User
from balance import notifications
from keycloak_client.django_client import get_keycloak_client


@shared_task
def send_monthly_balance(keycloak_id, month, year):
    user = User.objects.get(keycloak_id=keycloak_id)

    keycloak_client = get_keycloak_client()
    user_info = keycloak_client.get_user_info_by_id(keycloak_id=keycloak_id)
    email = user_info["email"]
    locale = (
        user_info["attributes"]["locale"]
        if "attributes" in user_info and "locale" in user_info["attributes"]
        else "en"
    )

    monthly_balance, created = MonthlyBalance.objects.get_or_create(
        owner=user, year=year, month=month
    )
    monthly_balance.currency_type = user.pref_currency_type
    # If an monthly_balance already existed, its gross_quantity
    # must be converted
    if not created:
        monthly_balance.gross_quantity = convert_or_fetch(
            monthly_balance.currency_type,
            user.pref_currency_type,
            monthly_balance.gross_quantity,
        )
    monthly_balance.expected_quantity = round(user.expected_monthly_balance, 2)
    monthly_balance.save()
    # Email sent
    notifications.send_monthly_balance(
        email,
        month,
        year,
        monthly_balance.gross_quantity,
        monthly_balance.expected_quantity,
        locale,
    )


@shared_task
def send_annual_balance(keycloak_id, year):
    user = User.objects.get(keycloak_id=keycloak_id)

    keycloak_client = get_keycloak_client()
    user_info = keycloak_client.get_user_info_by_id(keycloak_id=keycloak_id)
    email = user_info["email"]
    locale = (
        user_info["attributes"]["locale"]
        if "attributes" in user_info and "locale" in user_info["attributes"]
        else "en"
    )

    annual_balance, created = AnnualBalance.objects.get_or_create(owner=user, year=year)
    annual_balance.currency_type = user.pref_currency_type
    # If an annual_balance already existed, its gross_quantity
    # must be converted
    if not created:
        annual_balance.gross_quantity = convert_or_fetch(
            annual_balance.currency_type,
            user.pref_currency_type,
            annual_balance.gross_quantity,
        )
    annual_balance.expected_quantity = round(user.expected_annual_balance, 2)
    annual_balance.save()
    # Email sent
    notifications.send_annual_balance(
        email,
        year,
        annual_balance.gross_quantity,
        user.expected_annual_balance,
        annual_balance.expected_quantity,
        locale,
    )


@shared_task
def periodic_monthly_balance():
    # Yesterday is last day of month
    yesterday = now().date() - timedelta(days=1)
    month = yesterday.month
    year = yesterday.year
    for user in User.objects.all():
        if user.is_active and user.receive_email_balance:
            send_monthly_balance.delay(user.keycloak_id, month, year)


@shared_task
def periodic_annual_balance():
    # Yesterday is last day of year
    yesterday = now().date() - timedelta(days=1)
    year = yesterday.year
    for user in User.objects.all():
        if user.is_active and user.receive_email_balance:
            send_annual_balance.delay(user.keycloak_id, year)

from django.utils.timezone import now, timedelta
from celery import shared_task
from balance.models import AnnualBalance, MonthlyBalance
from coin.currency_converter_integration import convert_or_fetch
from custom_auth.models import User
from balance import notifications


@shared_task
def send_monthly_balance(user, month, year):
    monthly_balance, created = MonthlyBalance.objects.get_or_create(
        owner = user,
        year = year
    )
    monthly_balance.coin_type = user.pref_coin_type
    # If an monthly_balance already existed, its gross_quantity 
    # must be converted
    if not created:
        monthly_balance.gross_quantity = convert_or_fetch(
            monthly_balance.coin_type, 
            user.pref_coin_type,
            monthly_balance.gross_quantity
        )
    monthly_balance.expected_quantity = round(user.expected_monthly_balance, 2)
    monthly_balance.save()
    # Email sent
    notifications.send_monthly_balance(
        user.email,
        month,
        year,
        monthly_balance.gross_quantity,
        user.expected_monthly_balance,
        monthly_balance.expected_quantity,
        user.language
    )

@shared_task
def send_annual_balance(user, year):
    annual_balance, created = AnnualBalance.objects.get_or_create(
        owner = user,
        year = year
    )
    annual_balance.coin_type = user.pref_coin_type
    # If an annual_balance already existed, its gross_quantity 
    # must be converted
    if not created:
        annual_balance.gross_quantity = convert_or_fetch(
            annual_balance.coin_type, 
            user.pref_coin_type,
            annual_balance.gross_quantity
        )
    annual_balance.expected_quantity = round(user.expected_annual_balance, 2)
    annual_balance.save()
    # Email sent
    notifications.send_annual_balance(
        user.email,
        year,
        annual_balance.gross_quantity,
        user.expected_annual_balance,
        annual_balance.expected_quantity,
        user.language
    )


@shared_task
def periodic_monthly_balance():
    # Yesterday is last day of month
    yesterday = now().date() - timedelta(days=1)
    month = yesterday.month
    year = yesterday.year
    for user in User.objects:
        if user.verified and user.receive_email_balance:
            send_monthly_balance(user, month, year).delay()


@shared_task
def periodic_annual_balance():
    # Yesterday is last day of year
    yesterday = now().date() - timedelta(days=1)
    year = yesterday.year
    for user in User.objects:
        if user.verified and user.receive_email_balance:
            send_annual_balance(user, year).delay()
from django.db.models.signals import pre_save, pre_delete
from django.dispatch import receiver
from revenue.models import Revenue
from balance.utils import (
    check_dates_and_update_date_balances,
    update_or_create_annual_balance,
    update_or_create_monthly_balance
)
from coin.currency_converter_integration import convert_or_fetch
from custom_auth.models import User


@receiver(pre_save, sender=Revenue, dispatch_uid="revenue_pre_save")
def revenue_pre_save(sender, instance: Revenue, **kwargs):
    new_instance = instance
    try:
        old_instance = Revenue.objects.get(id=new_instance.id)
    except:
        old_instance = None
    owner = User.objects.get(id=new_instance.owner.id)
    # Create action
    if not old_instance:
        coin_from = new_instance.coin_type
        coin_to = owner.pref_coin_type
        real_quantity = new_instance.real_quantity
        converted_quantity = convert_or_fetch(
            coin_from, coin_to, real_quantity)
        new_instance.converted_quantity = converted_quantity
        owner.balance += converted_quantity
        owner.balance = round(owner.balance, 2)
        owner.save()
        # Create AnnualBalance or update it
        update_or_create_annual_balance(
            converted_quantity, owner,
            new_instance.date.year, True
        )
        # Create MonthlyBalance or update it
        update_or_create_monthly_balance(
            converted_quantity, owner,
            new_instance.date.year,
            new_instance.date.month, True
        )
    # Update action
    else:
        # In case there is a real quantity update
        if (
            new_instance.real_quantity != old_instance.real_quantity
            or new_instance.coin_type != old_instance.coin_type
        ):
            coin_from = new_instance.coin_type
            coin_to = owner.pref_coin_type
            real_quantity = new_instance.real_quantity
            converted_quantity = convert_or_fetch(
                coin_from, coin_to, real_quantity
            )
            new_instance.converted_quantity = converted_quantity
            converted_old_quantity = convert_or_fetch(
                old_instance.coin_type, coin_to,
                old_instance.real_quantity
            )
            owner.balance += converted_quantity \
                - converted_old_quantity
            owner.balance = round(owner.balance, 2)
            owner.save()
            # Create DateBalance or update it
            check_dates_and_update_date_balances(
                old_instance,
                converted_old_quantity,
                converted_quantity,
                new_instance.date
            )
        # In case there is only a change of date
        # month and year needs to be checked
        elif new_instance.date != old_instance.date:
            converted_quantity = new_instance.converted_quantity
            # Create DateBalance or update it
            check_dates_and_update_date_balances(
                old_instance, converted_quantity, None,
                new_instance.date
            )


@receiver(pre_delete, sender=Revenue, dispatch_uid="revenue_pre_delete")
def revenue_pre_delete(sender, instance: Revenue, **kwargs):
    owner = User.objects.get(id=instance.owner.id)
    coin_to = owner.pref_coin_type
    converted_quantity = convert_or_fetch(
        instance.coin_type, coin_to,
        instance.real_quantity
    )
    owner.balance -= converted_quantity
    owner.balance = round(owner.balance, 2)
    owner.save()
    # Create AnnualBalance or update it
    update_or_create_annual_balance(
        - converted_quantity, owner,
        instance.date.year, True
    )
    # Create MonthlyBalance or update it
    update_or_create_monthly_balance(
        - converted_quantity, owner,
        instance.date.year, instance.date.month, True
    )

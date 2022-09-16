from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from expense.models import Expense
from revenue.models import Revenue
from balance.tasks import compute_montly_balance, compute_annual_balance

#@receiver([post_save, post_delete], sender=Revenue, dispatch_uid="revenue_created_updated_deleted")
def revenue_created_updated_deleted(sender, instance, **kwargs):
    # Asynchronous signals (delay)
    compute_montly_balance.delay(
        instance.owner, instance.date.month, instance.date.year)
    compute_annual_balance.delay(
        instance.owner, instance.date.year)

#@receiver([post_save, post_delete], sender=Expense, dispatch_uid="expense_created_updated_deleted")
def expense_created_updated_deleted(sender, instance, **kwargs):
    # Asynchronous signals (delay)
    compute_montly_balance.delay(
        instance.owner, instance.date.month, instance.date.year)
    compute_annual_balance.delay(
        instance.owner, instance.date.year)
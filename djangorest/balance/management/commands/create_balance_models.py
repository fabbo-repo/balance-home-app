from django.core.management.base import BaseCommand
from django.conf import settings
import os

from balance.models import CoinType
from revenue.models import RevenueType
from expense.models import ExpenseType

"""
Will be executed with:
~~~
python manage.py create_balance_models
~~~
"""
class Command(BaseCommand):
    help = "Run the create_balance_models function "\
        + "that creates default RevenueType and ExpenseType" \
        + "models"

    def handle(self, *args, **options):
        self._create_default_rev_type()
        self._create_default_exp_type()


    def _create_default_rev_type(self):
        revenue_path = os.path.join(settings.MEDIA_ROOT, 'revenue')

        if not os.path.exists(revenue_path): return
        
        for rev_icon in os.listdir(revenue_path):
            if '.png' in rev_icon or '.jpg' in rev_icon and 'icon' in rev_icon:
                RevenueType.objects.update_or_create(
                    name=rev_icon.split('_icon')[0],
                    image='revenue/'+rev_icon
                )

    
    def _create_default_exp_type(self):
        expense_path = os.path.join(settings.MEDIA_ROOT, 'expense')

        if not os.path.exists(expense_path): return
        
        for exp_icon in os.listdir(expense_path):
            if '.png' in exp_icon or '.jpg' in exp_icon and 'icon' in exp_icon:
                ExpenseType.objects.update_or_create(
                    name=exp_icon.split('_icon')[0],
                    image='expense/'+exp_icon
                )
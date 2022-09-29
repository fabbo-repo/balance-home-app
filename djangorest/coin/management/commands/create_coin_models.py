from django.conf import settings
from django.core.management.base import BaseCommand
from coin.currency_converter_integration import update_exchange_data
from coin.models import CoinType

"""
Will be executed with:
~~~
python manage.py create_coin_models
~~~
"""
class Command(BaseCommand):
    help = "Run the create_balance_models function "\
        + "that creates default CoinType models"
    
    def handle(self, *args, **options):
        self._create_default_coin_type()


    def _create_default_coin_type(self):
        for coin_type_code in settings.COIN_TYPE_CODES:
            CoinType.objects.update_or_create(
                code=coin_type_code
            )
        update_exchange_data()

from django.core.management.base import BaseCommand

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
        # Euro coin
        CoinType.objects.update_or_create(
            code='EUR',
            name='euro'
        )
        # Unite State dollar
        CoinType.objects.update_or_create(
            code='USD',
            name='dollar'
        )

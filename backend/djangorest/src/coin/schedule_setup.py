import json
from django_celery_beat.models import PeriodicTask, IntervalSchedule

def schedule_setup():
    schedule_coin_exchanges_balance()


def schedule_coin_exchanges_balance():
    schedule, _ = IntervalSchedule.objects.get_or_create(
        period=IntervalSchedule.HOURS, 
        every=12
    )
    args = json.dumps([])
    PeriodicTask.objects.update_or_create(
        name="Coin exchange data update",
        interval=schedule,
        args=args,
        task="coin.tasks.periodic_update_exchange_data"
    )
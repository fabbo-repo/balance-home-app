import json
from django_celery_beat.models import PeriodicTask, CrontabSchedule

def schedule_setup():
    schedule_coin_exchanges_balance()


def schedule_coin_exchanges_balance():
    schedule, _ = CrontabSchedule.objects.get_or_create(
        minute="0", 
        hour="0",
        day_of_week="*",
        day_of_month="*",
        month_of_year="*"
    )
    args = json.dumps([])
    PeriodicTask.objects.update_or_create(
        name="Coin exchange data update",
        crontab=schedule,
        args=args,
        task="coin.tasks.periodic_update_exchange_data"
    )
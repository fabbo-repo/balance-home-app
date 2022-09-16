import json
from django_celery_beat.models import IntervalSchedule, PeriodicTask, CrontabSchedule


def schedule_setup():
    schedule_monthly_balance()
    schedule_annual_balance()


def schedule_monthly_balance():
    schedule, created = CrontabSchedule.objects.get_or_create(
        minute="30", 
        hour="7",
        day_of_month="1"
    )
    args = json.dumps([])
    PeriodicTask.objects.create(
        name="Monthly balance email and result",
        crontab=schedule,
        args=args,
        task="balance.tasks.periodic_monthly_balance"
    )


def schedule_annual_balance():
    schedule, created = CrontabSchedule.objects.get_or_create(
        minute="30", 
        hour="7",
        day_of_year="1"
    )
    args = json.dumps([])
    PeriodicTask.objects.create(
        name="Annual balance email and result",
        crontab=schedule,
        args=args,
        task="balance.tasks.periodic_annual_balance"
    )
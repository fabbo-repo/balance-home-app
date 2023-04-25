import json
from django_celery_beat.models import PeriodicTask, IntervalSchedule
from django.conf import settings

def schedule_setup():
    schedule_unverified_users_deletion()


def schedule_unverified_users_deletion():
    day_schedule, created = IntervalSchedule.objects.get_or_create(
        period=IntervalSchedule.DAYS,
        every=settings.UNVERIFIED_USER_DAYS
    )
    args = json.dumps([])
    PeriodicTask.objects.update_or_create(
        name="Unverified users deletion",
        interval=day_schedule,
        args=args,
        task="custom_auth.tasks.remove_unverified_users"
    )
from django.core.management.base import BaseCommand
from app_auth.schedule_setup import schedule_setup


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py schedule_users_delete
    ~~~
    """

    help = "Run the schedule_users_delete function"

    def handle(self, *args, **options):
        schedule_setup()
        print("DONE")

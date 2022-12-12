from django.core.management.base import BaseCommand
from custom_auth.schedule_setup import schedule_setup


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py users_schedule_setup
    ~~~
    """
    
    help = "Run the users_schedule_setup function"

    def handle(self, *args, **options):
        schedule_setup()

from django.core.management.base import BaseCommand

from coin.schedule_setup import schedule_setup


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py schedule_setup
    ~~~
    """
    
    help = "Run the schedule_setup function"

    def handle(self, *args, **options):
        schedule_setup()

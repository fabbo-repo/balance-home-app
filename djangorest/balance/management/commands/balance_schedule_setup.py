from django.core.management.base import BaseCommand
from balance.schedule_setup import schedule_setup

"""
Will be executed with:
~~~
python manage.py schedule_setup
~~~
"""
class Command(BaseCommand):
    help = "Run the schedule_setup function"

    def handle(self, *args, **options):
        schedule_setup()

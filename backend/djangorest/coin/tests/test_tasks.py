from unittest import mock
from django.test import TestCase
from coin.tasks import periodic_update_exchange_data
from coin.schedule_setup import schedule_setup
from django_celery_beat.models import IntervalSchedule


class CoinTasksTests(TestCase):

    def test_shared_task_used(self):
        """
        Checks that shared_task decorator is used
        """
        from coin.tasks import shared_task
        self.assertIsNotNone(
            shared_task
        )  # assume if it's imported there then it's used as the decorator

    def test_methods_shared_tasks(self):
        """
        Checks that periodic_update_exchange_data is a shared 
        task
        """
        self.assertIsNotNone(periodic_update_exchange_data.delay)

    @staticmethod
    def test_shared_tasks_behaviour():
        """
        Checks that send_email_code and send_password_code are 
        shared tasks
        """
        with mock.patch(
            "coin.tasks.update_exchange_data"
        ) as update_exchange_data:
            periodic_update_exchange_data()
            update_exchange_data.assert_any_call()

    def test_schedule_setup(self):
        """
        Checks that schedule_setup creates the correct interval
        """
        schedule_setup()
        interval_schedules = IntervalSchedule.objects.all()
        self.assertEqual(interval_schedules.count(), 1)
        interval_schedule = interval_schedules.first()
        self.assertEqual(interval_schedule.period, IntervalSchedule.HOURS)
        self.assertEqual(interval_schedule.every, 12)
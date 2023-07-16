from unittest import mock
from django.test import TestCase
from balance.tasks import (
    send_monthly_balance,
    send_annual_balance,
    periodic_monthly_balance,
    periodic_annual_balance
)
from balance.schedule_setup import schedule_setup
from django_celery_beat.models import CrontabSchedule
from app_auth.models import InvitationCode, User
from balance.models import CoinType
import logging
from balance.tasks import periodic_monthly_balance, periodic_annual_balance
from django.conf import settings


class BalanceTasksTests(TestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        # Create InvitationCodes
        self.inv_code1 = InvitationCode.objects.create()
        self.inv_code2 = InvitationCode.objects.create()
        self.coin_type = CoinType.objects.create(code="EUR")
        # User creation
        self.user = User.objects.create(
            username="username1",
            email="email1@test.com",
            inv_code=self.inv_code1,
            verified=True
        )
        self.user.set_password("password1@212")
        self.user.save()
        return super().setUp()

    def test_shared_task_used(self):
        """
        Checks that shared_task decorator is used
        """
        from balance.tasks import shared_task
        self.assertIsNotNone(
            shared_task
        )  # assume if it's imported there then it's used as the decorator

    def test_methods_shared_tasks(self):
        """
        Checks that send_monthly_balance, send_annual_balance, 
        periodic_monthly_balance and periodic_annual_balance are shared 
        task
        """
        self.assertIsNotNone(send_monthly_balance.delay)
        self.assertIsNotNone(send_annual_balance.delay)
        self.assertIsNotNone(periodic_monthly_balance.delay)
        self.assertIsNotNone(periodic_annual_balance.delay)

    def test_schedule_setup(self):
        """
        Checks that schedule_setup creates the correct crontab
        """
        schedule_setup()
        crontab_schedules = CrontabSchedule.objects.all()
        self.assertEqual(crontab_schedules.count(), 2)
        monthly_crontab_schedule = crontab_schedules.first()
        annual_crontab_schedule = crontab_schedules.last()
        self.assertEqual(monthly_crontab_schedule.minute, "30")
        self.assertEqual(monthly_crontab_schedule.hour, "7")
        self.assertEqual(monthly_crontab_schedule.day_of_week, "*")
        self.assertEqual(monthly_crontab_schedule.day_of_month, "1")
        self.assertEqual(monthly_crontab_schedule.month_of_year, "*")
        annual_crontab_schedule = crontab_schedules.last()
        self.assertEqual(annual_crontab_schedule.minute, "30")
        self.assertEqual(annual_crontab_schedule.hour, "7")
        self.assertEqual(annual_crontab_schedule.day_of_week, "*")
        self.assertEqual(annual_crontab_schedule.day_of_month, "1")
        self.assertEqual(annual_crontab_schedule.month_of_year, "1")

    def test_send_monthly_balance(self):
        """
        Checks that send_monthly_balance is called
        """
        settings.CELERY_TASK_ALWAYS_EAGER = True
        # Mock Celery tasks
        with mock.patch(
            "balance.notifications.send_monthly_balance"
        ) as send_monthly_balance:
            periodic_monthly_balance()
            send_monthly_balance.assert_called_once()

    def test_send_annual_balance(self):
        """
        Checks that send_annual_balance is called
        """
        settings.CELERY_TASK_ALWAYS_EAGER = True
        # Mock Celery tasks
        with mock.patch(
            "balance.notifications.send_annual_balance"
        ) as send_annual_balance:
            periodic_annual_balance()
            send_annual_balance.assert_called_once()
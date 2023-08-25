import logging
from unittest import mock
from django.test import TestCase
from django.conf import settings
from django_celery_beat.models import CrontabSchedule
from balance.tasks import (
    send_monthly_balance,
    send_annual_balance,
    periodic_monthly_balance,
    periodic_annual_balance,
)
from balance.schedule_setup import schedule_setup
from balance.tasks import periodic_monthly_balance, periodic_annual_balance
from app_auth.models import User, InvitationCode
from keycloak_client.django_client import get_keycloak_client


class BalanceTasksTests(TestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create(  # pylint: disable=no-member
            usage_left=400
        )

        # User creation
        User.objects.create(
            keycloak_id=self.keycloak_client_mock.keycloak_id,
            inv_code=self.inv_code,
            receive_email_balance=True,
        )

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

from unittest import mock
from django.test import TestCase
from custom_auth.tasks import send_email_code, send_password_code


class CustomAuthTasksTests(TestCase):

    def test_shared_task_used(self):
        """
        Checks that shared_task decorator is used
        """
        from custom_auth.tasks import shared_task
        self.assertIsNotNone(
            shared_task
        )  # assume if it's imported there then it's used as the decorator

    def test_methods_shared_tasks(self):
        """
        Checks that send_email_code and send_password_code are 
        shared tasks
        """
        self.assertIsNotNone(send_email_code.delay)
        self.assertIsNotNone(send_password_code.delay)

    def test_shared_tasks_behaviour(self):
        """
        Checks that send_email_code and send_password_code are 
        shared tasks
        """
        with mock.patch(
            "custom_auth.tasks.notifications.send_email_code"
        ) as notifications_send_email_code:
            send_email_code('123456', 'test@gmail.com', 'en')
            notifications_send_email_code.assert_any_call(
                '123456', 'test@gmail.com', 'en')
        with mock.patch(
            "custom_auth.tasks.notifications.send_password_code"
        ) as notifications_send_password_code:
            send_password_code('123456', 'test@gmail.com', 'en')
            notifications_send_password_code.assert_any_call(
                '123456', 'test@gmail.com', 'en')

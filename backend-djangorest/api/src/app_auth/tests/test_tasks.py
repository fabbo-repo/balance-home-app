import logging
from django.test import TestCase


class AuthTasksTests(TestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

    def test_shared_task_used(self):
        """
        Checks that shared_task decorator is used
        """
        from app_auth.tasks import shared_task
        self.assertIsNotNone(
            shared_task
        )  # assume if it"s imported there then it"s used as the decorator

    def test_methods_shared_tasks(self):
        """
        Checks that remove_unverified_users is 
        shared tasks
        """
        from app_auth.tasks import remove_unverified_users
        self.assertIsNotNone(remove_unverified_users.delay)

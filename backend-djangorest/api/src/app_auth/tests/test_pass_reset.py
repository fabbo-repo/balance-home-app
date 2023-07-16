import logging
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from django.conf import settings
from django.utils.timezone import timedelta
from django.core.cache import cache
from app_auth.models import InvitationCode, User
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class PasswordResetTests(APITestCase):
    def setUp(self):
        # Mock Celery tasks
        settings.CELERY_TASK_ALWAYS_EAGER = True

        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        # Throttling is stored in cache
        cache.clear()

        self.reset_password_url = reverse("reset-password")
        self.user_get_del_url = reverse("user-put-get-del")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()  # pylint: disable=no-member

        # User data
        self.user_data = {
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "locale": self.keycloak_client_mock.locale
        }
        # User creation
        User.objects.create(
            keycloak_id=self.keycloak_client_mock.keycloak_id,
            inv_code=self.inv_code
        )
        return super().setUp()

    def send_mail(self, email):
        return test_utils.post(
            self.client,
            self.reset_password_url,
            data={"email": email}
        )

    def test_send_password_reset_mail(self):
        """
        Checks that password reset mail is sent
        """
        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        self.assertTrue(self.keycloak_client_mock.reset_password_mail_sent)

    def test_send_four_password_reset_same_day(self):
        """
        Checks that requesting a password reset code more than 3 times per day is not allowed
        """
        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        user.date_pass_reset = user.date_pass_reset - timedelta(minutes=10)
        user.save()

        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        user.date_pass_reset = user.date_pass_reset - timedelta(minutes=10)
        user.save()

        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        user.date_pass_reset = user.date_pass_reset - timedelta(minutes=10)
        user.save()

        response = self.send_mail(self.user_data["email"])
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_send_four_password_reset_diferent_day(self):
        """
        Checks that requesting a password reset code more than 3 times in diferent day is allowed
        """
        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        user.date_pass_reset = user.date_pass_reset - timedelta(minutes=10)
        user.save()

        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        user.date_pass_reset = user.date_pass_reset - timedelta(minutes=10)
        user.save()

        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)
        user = User.objects.get(
            keycloak_id=self.keycloak_client_mock.keycloak_id)
        user.date_pass_reset = user.date_pass_reset - timedelta(days=1)
        user.save()

        response = self.send_mail(self.user_data["email"])
        self.assertEqual(status.HTTP_204_NO_CONTENT, response.status_code)

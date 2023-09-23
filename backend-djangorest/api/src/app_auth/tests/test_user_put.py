import logging
import os
import tempfile
import shutil
from rest_framework.test import APITestCase
from rest_framework import status
from coin.models import CoinType
from app_auth.models import User, InvitationCode
from app_auth.exceptions import (
    CURRENCY_TYPE_CHANGED_ERROR
)
from PIL import Image
from django.conf import settings
from django.core.cache import cache
from django.urls import reverse
import core.tests.utils as test_utils
from keycloak_client.django_client import get_keycloak_client


class UserPutTests(APITestCase):
    def setUp(self):
        settings.CELERY_TASK_ALWAYS_EAGER = True

        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)

        # Throttling is stored in cache
        cache.clear()

        self.user_post_url = reverse("user-post")
        self.user_put_url = reverse("user-put-get-del")

        self.keycloak_client_mock = get_keycloak_client()

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()  # pylint: disable=no-member
        # User data
        CoinType.objects.create(code="USD")  # pylint: disable=no-member
        pref_currency_type = CoinType.objects.create(  # pylint: disable=no-member
            code="EUR")
        self.user_data = {
            "username": self.keycloak_client_mock.username,
            "email": self.keycloak_client_mock.email,
            "password": self.keycloak_client_mock.password,
            "inv_code": str(self.inv_code.code),
            "pref_currency_type": str(pref_currency_type.code),
            "locale": self.keycloak_client_mock.locale
        }
        # User creation
        user = User.objects.create(
            keycloak_id=self.keycloak_client_mock.keycloak_id,
            inv_code=self.inv_code,
            pref_currency_type=pref_currency_type
        )
        user.set_password(self.user_data["password"])
        user.save()
        # Authenticate
        test_utils.authenticate_user(self.client)
        return super().setUp()

    def user_patch(self, data):
        return test_utils.patch(
            self.client,
            self.user_put_url,
            data=data,
        )

    def user_patch_image(self, image):
        return test_utils.patch_image(
            self.client,
            self.user_put_url,
            data={"image": image}
        )

    def temporary_image(self):
        image = Image.new("RGB", (100, 100))
        tmp_file = tempfile.NamedTemporaryFile(
            suffix=".jpg", prefix="test_img_")
        image.save(tmp_file, "jpeg")
        tmp_file.seek(0)
        return tmp_file

    def test_change_user_name(self):
        """
        Checks that username is changed
        """
        response = self.user_patch({"username": "test2"})
        self.assertEqual(status.HTTP_200_OK, response.status_code)
        self.assertEqual("test2", self.keycloak_client_mock.updated_username)

    def test_change_user_annual_balance(self):
        """
        Checks that annual balance is changed
        """
        response = self.user_patch({"expected_annual_balance": 10})
        self.assertEqual(status.HTTP_200_OK, response.status_code)
        keycloak_id = self.keycloak_client_mock.keycloak_id
        user = User.objects.get(keycloak_id=keycloak_id)
        self.assertEqual(user.expected_annual_balance, 10)

    def test_change_user_monthly_balance(self):
        """
        Checks that montly balance is changed
        """
        response = self.user_patch({"expected_monthly_balance": 10})
        self.assertEqual(status.HTTP_200_OK, response.status_code)
        keycloak_id = self.keycloak_client_mock.keycloak_id
        user = User.objects.get(keycloak_id=keycloak_id)
        self.assertEqual(user.expected_monthly_balance, 10)

    def test_change_user_image(self):
        """
        Checks that image is uploaded
        """
        response = self.user_patch_image(self.temporary_image())
        self.assertEqual(status.HTTP_200_OK, response.status_code)
        keycloak_id = self.keycloak_client_mock.keycloak_id
        user = User.objects.get(keycloak_id=keycloak_id)
        generated_dir = os.path.join(
            str(settings.BASE_DIR), "media", "user_"+str(user.id))
        self.assertTrue(os.path.exists(generated_dir))
        if os.path.exists(generated_dir):
            shutil.rmtree(generated_dir)

    def test_change_pref_currency_type(self):
        """
        Checks that pref currency type is changed
        """
        response = test_utils.patch(
            self.client,
            self.user_put_url,
            data={
                "pref_currency_type": "USD",
                "balance": "0"
            }
        )
        self.assertEqual(status.HTTP_200_OK, response.status_code)
        response = test_utils.patch(
            self.client,
            self.user_put_url,
            data={
                "pref_currency_type": "EUR",
                "balance": "0"
            }
        )
        self.assertEqual(status.HTTP_400_BAD_REQUEST, response.status_code)
        self.assertEqual(
            CURRENCY_TYPE_CHANGED_ERROR,
            response.data["error_code"]
        )

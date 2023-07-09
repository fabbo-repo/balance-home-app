from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from app_auth.models import User, InvitationCode
import logging
from django.conf import settings
import tempfile
from PIL import Image
import shutil
import os
from django.core.cache import cache
import core.tests.utils as test_utils
from unittest import mock


class UserPutTests(APITestCase):
    def setUp(self):
        # Mock Celery tasks
        settings.CELERY_TASK_ALWAYS_EAGER = True
        mock.patch("app_auth.tasks.notifications.send_email_code",
                   return_value=None)
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)
        # Throttling is stored in cache
        cache.clear()

        self.user_post_url = reverse('user_post')
        self.change_password_url = reverse('change_password')
        self.user_put_url = reverse('user_put_get_del')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        # User data
        CoinType.objects.create(code='USD')
        pref_coin_type = CoinType.objects.create(code='EUR')
        self.user_data = {
            "username": "username",
            "email": "email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            "inv_code": str(self.inv_code.code),
            'pref_coin_type': pref_coin_type.code,
            'language': 'en'
        }
        self.credentials = {
            "email": "email@test.com",
            "password": "password1@212"
        }
        # User creation
        user = User.objects.create(
            username=self.user_data["username"],
            email=self.user_data["email"],
            inv_code=self.inv_code,
            pref_coin_type=pref_coin_type,
            verified=True
        )
        user.set_password(self.user_data['password'])
        user.save()
        # Authenticate
        test_utils.authenticate_user(self.client, self.credentials)
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
            data={'image': image}
        )

    def temporary_image(self):
        image = Image.new('RGB', (100, 100))
        tmp_file = tempfile.NamedTemporaryFile(
            suffix='.jpg', prefix="test_img_")
        image.save(tmp_file, 'jpeg')
        tmp_file.seek(0)
        return tmp_file

    def test_change_user_name(self):
        """
        Checks that username is changed
        """
        response = self.user_patch({"username": "test_2"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.username, "test_2")

    def test_change_user_email(self):
        """
        Checks that email is changed
        """
        self.user_patch({"email": "test2@gmail.com"})
        try:
            User.objects.get(email="test2@gmail.com")
            self.assertTrue(False)
        except:
            self.assertTrue(True)
        try:
            User.objects.get(email=self.user_data["email"])
            self.assertTrue(True)
        except:
            self.assertTrue(False)

    def test_change_user_annual_balance(self):
        """
        Checks that annual balance is changed
        """
        response = self.user_patch({"expected_annual_balance": 10})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.expected_annual_balance, 10)

    def test_change_user_monthly_balance(self):
        """
        Checks that montly balance is changed
        """
        response = self.user_patch({"expected_monthly_balance": 10})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.expected_monthly_balance, 10)

    def test_change_user_image(self):
        """
        Checks that image is uploaded
        """
        response = self.user_patch_image(self.temporary_image())
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        generated_dir = os.path.join(
            str(settings.BASE_DIR), 'media', 'user_'+str(user.id))
        self.assertTrue(os.path.exists(generated_dir))
        if os.path.exists(generated_dir):
            shutil.rmtree(generated_dir)

    def test_change_password(self):
        """
        Checks that password is changed
        """
        # Wrong old password
        response = test_utils.post(
            self.client,
            self.change_password_url,
            data={
                "old_password": "password1@214",
                "new_password": "password1@213"
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # Same password
        response = test_utils.post(
            self.client,
            self.change_password_url,
            data={
                "old_password": "password1@212",
                "new_password": "password1@212"
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # Correct passwords
        response = test_utils.post(
            self.client,
            self.change_password_url,
            data={
                "old_password": "password1@212",
                "new_password": "password1@213"
            }
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Check authentication with new password
        self.credentials["password"] = "password1@213"
        response = test_utils.authenticate_user(self.client, self.credentials)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_change_pref_coin_type(self):
        """
        Checks that pref coin type is changed
        """
        response = test_utils.patch(
            self.client,
            self.user_put_url,
            data={
                "pref_coin_type": "USD",
                "balance": "0"
            }
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        response = test_utils.patch(
            self.client,
            self.user_put_url,
            data={
                "pref_coin_type": "EUR",
                "balance": "0"
            }
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertTrue("pref_coin_type" in str(response.content))

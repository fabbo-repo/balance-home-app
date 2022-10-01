from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import User, InvitationCode
import logging
import json
from django.conf import settings
import tempfile
from PIL import Image
import shutil
import os

class UserPutTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.user_post_url=reverse('user_post')
        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.change_password_url=reverse('change_password')
        self.user_put_url=reverse('user_put_get_del')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        # User data
        self.user_data={
            "username":"username",
            "email":"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            "inv_code": str(self.inv_code.code),
            'pref_coin_type': 
                str(CoinType.objects.create(code='EUR').code),
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
            verified=True
        )
        user.set_password(self.user_data['password'])
        user.save()
        # Jwt obtain
        self.jwt = self.jwt_obtain().data["access"]
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(self.jwt))
        return super().setUp()
    
    def jwt_obtain(self, credentials=None) :
        if credentials == None: credentials = self.credentials
        return self.client.post(
            self.jwt_obtain_url,
            data=json.dumps(credentials),
            content_type="application/json"
        )

    def user_patch(self, data) :
        return self.client.patch(
            self.user_put_url,
            data=json.dumps(data),
            content_type="application/json"
        )
    
    def user_patch_image(self, image) :
        return self.client.patch(
            self.user_put_url,
            data={'image':image}
        )
    
    def temporary_image(self):
        image = Image.new('RGB', (100, 100))
        tmp_file = tempfile.NamedTemporaryFile(suffix='.jpg', prefix="test_img_")
        image.save(tmp_file, 'jpeg')
        tmp_file.seek(0)
        return tmp_file

    def test_change_user_name(self):
        """
        Checks that username is changed
        """
        response = self.user_patch({"username":"test_2"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.username, "test_2")

    def test_change_user_email(self):
        """
        Checks that email is changed
        """
        response = self.user_patch({"email":"test2@gmail.com"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email="test2@gmail.com")
        self.assertFalse(user.verified)

    def test_change_user_annual_balance(self):
        """
        Checks that annual balance is changed
        """
        response = self.user_patch({"expected_annual_balance":10})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.expected_annual_balance, 10)
    
    def test_change_user_monthly_balance(self):
        """
        Checks that montly balance is changed
        """
        response = self.user_patch({"expected_monthly_balance":10})
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
            str(settings.BASE_DIR),'media','user_'+str(user.id))
        self.assertTrue(os.path.exists(generated_dir))
        if os.path.exists(generated_dir):
            shutil.rmtree(generated_dir)

    def test_change_password(self):
        """
        Checks that password is changed
        """
        response=self.client.post(
            self.change_password_url,
            data=json.dumps(
                {
                    "old_password": "password1@212",
                    "new_password": "password1@213"
                }
            ),
            content_type="application/json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.credentials["password"]= "password1@213"
        response = self.jwt_obtain()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
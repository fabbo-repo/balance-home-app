from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
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

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        self.inv_code.save()
        # User data
        self.user_data={
            "username":"username",
            "email":"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            "inv_code": str(self.inv_code.code)
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
        self.user_put_url=reverse('user_put_get_del', args=[user.id])
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

    def user_put(self, data) :
        return self.client.put(
            self.user_put_url,
            data=json.dumps(data),
            content_type="application/json"
        )
    
    def user_put_image(self, image) :
        return self.client.put(
            self.user_put_url,
            data={'image':image}
        )
    
    def temporary_image(self):
        image = Image.new('RGB', (100, 100))
        tmp_file = tempfile.NamedTemporaryFile(suffix='.jpg', prefix="test_img_")
        image.save(tmp_file, 'jpeg')
        tmp_file.seek(0)
        return tmp_file

    """
    Checks that username is changed
    """
    def test_change_user_name(self):
        response = self.user_put({"username":"test_2"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.username, "test_2")

    """
    Checks that email is changed
    """
    def test_change_user_email(self):
        response = self.user_put({"email":"test2@gmail.com"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email="test2@gmail.com")
        self.assertFalse(user.verified)

    """
    Checks that annual balance is changed
    """
    def test_change_user_annual_balance(self):
        response = self.user_put({"annual_balance":10})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.annual_balance, 10)
    
    """
    Checks that montly balance is changed
    """
    def test_change_user_monthly_balance(self):
        response = self.user_put({"monthly_balance":10})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        self.assertEqual(user.monthly_balance, 10)
        

    """
    Checks that image is uploaded
    """
    def test_change_user_image(self):
        response = self.user_put_image(self.temporary_image())
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data["email"])
        generated_dir = os.path.join(
            str(settings.BASE_DIR),'media','user_'+str(user.id))
        self.assertTrue(os.path.exists(generated_dir))
        if os.path.exists(generated_dir):
            shutil.rmtree(generated_dir)
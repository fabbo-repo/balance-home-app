import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from coin.models import CoinType
from custom_auth.models import InvitationCode, User
import logging
from django.conf import settings


class UrlPermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests
        logging.disable(logging.WARNING)
        # For testing, code threshold to 0 seconds
        settings.EMAIL_CODE_THRESHOLD = 0

        self.jwt_obtain_url = reverse('jwt_obtain_pair')
        self.jwt_refresh_url = reverse('jwt_refresh')
        self.user_post_url = reverse('user_post')
        self.user_put_get_del_url = reverse('user_put_get_del')
        self.change_password_url = reverse('change_password')
        self.reset_password_start_url = reverse('reset_password_start')
        self.reset_password_verify_url = reverse('reset_password_verify')
        self.email_code_send_url = reverse('email_code_send')
        self.email_code_verify_url = reverse('email_code_verify')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        # Test user data
        self.user_data1 = {
            'username': "username1",
            'email': "email1@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
            'pref_coin_type':
                str(CoinType.objects.create(code='EUR').code),
            'language': 'en'
        }
        self.credentials1 = {
            'email': "email1@test.com",
            "password": "password1@212"
        }
        self.user_data2 = {
            'username': "username2",
            'email': "email2@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(self.inv_code.code),
            'pref_coin_type':
                str(CoinType.objects.create(code='USD').code),
            'language': 'en'
        }
        self.credentials2 = {
            'email': "email2@test.com",
            "password": "password1@212"
        }
        # User creation
        user = User.objects.create(
            username=self.user_data1["username"],
            email=self.user_data1["email"],
            inv_code=self.inv_code,
            verified=True
        )
        user.set_password(self.user_data1['password'])
        user.save()
        user = User.objects.create(
            username=self.user_data2["username"],
            email=self.user_data2["email"],
            inv_code=self.inv_code,
            verified=True
        )
        user.set_password(self.user_data2['password'])
        user.save()
        return super().setUp()

    def get(self, url):
        return self.client.get(url)

    def post(self, url, data={}):
        return self.client.post(
            url, json.dumps(data),
            content_type="application/json"
        )

    def patch(self, url, data={}):
        return self.client.patch(
            url, json.dumps(data),
            content_type="application/json"
        )

    def delete(self, url):
        return self.client.delete(url)

    def test_jwt_obtain_url(self):
        """
        Checks permissions with JWT obtain
        """
        response = self.post(self.jwt_obtain_url, self.credentials1)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        response = self.post(self.jwt_obtain_url, self.credentials2)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_jwt_refresh_url(self):
        """
        Checks permissions with JWT refresh
        """
        refresh = self.post(self.jwt_obtain_url,
                            self.credentials1).data['refresh']
        response = self.post(self.jwt_refresh_url, {'refresh': refresh})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        refresh = self.post(self.jwt_obtain_url,
                            self.credentials2).data['refresh']
        response = self.post(self.jwt_refresh_url, {'refresh': refresh})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_post_url(self):
        """
        Checks permissions with User post
        """
        user_data_aux = self.user_data1
        user_data_aux['email'] = 'test2@email.com'
        user_data_aux['username'] = 'test2'
        response = self.post(self.user_post_url, user_data_aux)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_user_patch_url(self):
        """
        Checks permissions with User patch
        """
        # Try without authentication
        user_data_aux = {'username': 'test'}
        response = self.patch(self.user_put_get_del_url, user_data_aux)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt = self.post(self.jwt_obtain_url, self.credentials1).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response = self.patch(self.user_put_get_del_url, user_data_aux)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_get_url(self):
        """
        Checks permissions with User get
        """
        # Try without authentications
        response = self.get(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt = self.post(self.jwt_obtain_url, self.credentials1).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response = self.get(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_user_get_url(self):
        """
        Checks permissions with User del
        """
        # Try without authentications
        response = self.delete(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt = self.post(self.jwt_obtain_url, self.credentials1).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response = self.delete(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_email_code_send_url(self):
        """
        Checks permissions with email code send
        """
        user = User.objects.get(email=self.user_data1['email'])
        user.verified = False
        user.save()
        response = self.post(self.email_code_send_url, {
                             'email': self.user_data1['email']})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_email_code_verify_url(self):
        """
        Checks permissions with email code verify
        """
        # Send code
        user = User.objects.get(email=self.user_data1['email'])
        user.verified = False
        user.save()
        self.post(self.email_code_send_url, {'email': self.user_data1['email']})
        # Verify code
        user = User.objects.get(email=self.user_data1['email'])
        response = self.post(self.email_code_send_url, {
            'email': self.user_data1['email'],
            'code': user.code_sent
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_change_password_url(self):
        """
        Checks permissions with change password
        """
        # Try without authentications
        data = {
            'old_password': self.user_data1['password'],
            'new_password': 'pass@123ua3ss'
        }
        response = self.post(self.change_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt = self.post(self.jwt_obtain_url, self.credentials1).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response = self.post(self.change_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_reset_password_url(self):
        """
        Checks permissions with reset password
        """
        # Try without authentication
        response = self.post(self.reset_password_start_url)
        self.assertNotEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        response = self.post(self.reset_password_verify_url)
        self.assertNotEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Begin process
        response = self.post(self.reset_password_start_url,
                             {
                                 "email": self.user_data1['email']
                             }
                             )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user = User.objects.get(email=self.user_data1['email'])
        data = {
            "email": self.user_data1['email'],
            'code': user.pass_reset,
            'new_password': 'pass@123ua3ss'
        }
        response = self.post(self.reset_password_verify_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

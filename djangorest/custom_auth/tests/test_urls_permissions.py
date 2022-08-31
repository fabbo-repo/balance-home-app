import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from custom_auth.models import InvitationCode, User
import logging
from django.conf import settings

class UrlPermissionsTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)
        # For testing, code threshold to 0 seconds
        settings.EMAIL_CODE_THRESHOLD = 0

        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.jwt_refresh_url=reverse('jwt_refresh')
        self.user_post_url=reverse('user_post')
        self.user_put_get_del_url=reverse('user_put_get_del')
        self.change_password_url=reverse('change_password')
        self.reset_password_url=reverse('reset_password')
        self.email_code_send_url=reverse('email_code_send')
        self.email_code_verify_url=reverse('email_code_verify')

        # Create InvitationCode
        inv_code = InvitationCode.objects.create()
        inv_code.save()
        # Test user data
        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212",
            "password2": "password1@212",
            'inv_code': str(inv_code.code)
        }
        self.credentials = {
            'email':"email@test.com",
            "password": "password1@212"
        }
        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
        self.inv_code.save()
        # User creation
        user = User.objects.create(
            username=self.user_data["username"],
            email=self.user_data["email"],
            inv_code=self.inv_code,
            verified=True
        )
        user.set_password(self.user_data['password'])
        user.save()
        return super().setUp()
    
    def get(self, url) :
        return self.client.get(url)
    
    def post(self, url, data={}) :
        return self.client.post(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def put(self, url, data={}) :
        return self.client.put(
            url, json.dumps(data),
            content_type="application/json"
        )
    
    def delete(self, url) :
        return self.client.delete(url)
    
    """
    Checks permissions with JWT obtain
    """
    def test_jwt_obtain_url(self):
        response=self.post(self.jwt_obtain_url, self.credentials)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    """
    Checks permissions with JWT refresh
    """
    def test_jwt_refresh_url(self):
        refresh=self.post(self.jwt_obtain_url, self.credentials).data['refresh']
        response=self.post(self.jwt_refresh_url, {'refresh':refresh})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    """
    Checks permissions with User post
    """
    def test_user_post_url(self):
        user_data2=self.user_data
        user_data2['email']='test2@email.com'
        user_data2['username']='test2'
        response=self.post(self.user_post_url, user_data2)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
    """
    Checks permissions with User put
    """
    def test_user_put_url(self):
        # Try without authentications
        user_data2={'username':'test2'}
        response=self.put(self.user_put_get_del_url, user_data2)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, self.credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response=self.put(self.user_put_get_del_url, user_data2)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    """
    Checks permissions with User get
    """
    def test_user_get_url(self):
        # Try without authentications
        response=self.get(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, self.credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response=self.get(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    """
    Checks permissions with User del
    """
    def test_user_get_url(self):
        # Try without authentications
        response=self.delete(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, self.credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response=self.delete(self.user_put_get_del_url)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    """
    Checks permissions with email code send
    """
    def test_email_code_send_url(self):
        user=User.objects.get(email=self.user_data['email'])
        user.verified=False
        user.save()
        response=self.post(self.email_code_send_url, {'email':self.user_data['email']})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    """
    Checks permissions with email code verify
    """
    def test_email_code_verify_url(self):
        # Send code
        user=User.objects.get(email=self.user_data['email'])
        user.verified=False
        user.save()
        self.post(self.email_code_send_url, {'email':self.user_data['email']})
        # Verify code
        user=User.objects.get(email=self.user_data['email'])
        response=self.post(self.email_code_send_url, {
            'email':self.user_data['email'],
            'code': user.code_sent
        })
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
    """
    Checks permissions with change password
    """
    def test_change_password_url(self):
        # Try without authentications
        data={
            'old_password': self.user_data['password'],
            'new_password': 'pass@123ua3ss'
        }
        response=self.post(self.change_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, self.credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response=self.post(self.change_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    """
    Checks permissions with reset password
    """
    def test_reset_password_url(self):
        # Try without authentication
        response=self.get(self.reset_password_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        # Get jwt token
        jwt=self.post(self.jwt_obtain_url, self.credentials).data['access']
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
        # Try with authentication
        response=self.get(self.reset_password_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user=User.objects.get(email=self.user_data['email'])
        data={
            'code': user.pass_reset,
            'new_password': 'pass@123ua3ss'
        }
        response=self.post(self.reset_password_url, data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
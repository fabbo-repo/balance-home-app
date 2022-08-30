import time
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from custom_auth.models import InvitationCode, User
import logging
from django.conf import settings

class JwtCodeTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.user_post_url=reverse('user_post')
        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.jwt_refresh_url=reverse('jwt_refresh')
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
        # user_post User:
        self.user_post()
        return super().setUp()
    
    def user_post(self, user_data=None) :
        if user_data == None: user_data = self.user_data
        return self.client.post(
            self.user_post_url,
            data=json.dumps(user_data),
            content_type="application/json"
        )
    
    def jwt_obtain(self, credentials=None) :
        if credentials == None: credentials = self.credentials
        return self.client.post(
            self.jwt_obtain_url,
            data=json.dumps(credentials),
            content_type="application/json"
        )
    
    def send_code(self, email=None) :
        if email == None: email = self.user_data['email']
        return self.client.post(
            self.email_code_send_url,
            data=json.dumps({'email': email}),
            content_type="application/json"
        )
    
    def verify_code(self, code, email=None) :
        if email == None: email = self.user_data['email']
        return self.client.post(
            self.email_code_verify_url,
            data=json.dumps({'email': email, 'code': code}),
            content_type="application/json"
        )



    """
    Checks that an unverified user should not be able to obtain jwt
    """
    def test_jwt_obtain_unverified_user(self):
        response=self.jwt_obtain()
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('verified', response.data)

    """
    Checks that an inactive user should not be able to obtain jwt
    """
    def test_jwt_obtain_inactive_user(self):
        user=User.objects.get(email=self.user_data['email'])
        user.is_active=False
        user.save()
        response=self.jwt_obtain()
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data['detail'], 'No active account found with the given credentials')

    """
    Checks that an nonexistent user should not be able to obtain jwt
    """
    def test_jwt_obtain_nonexistent_user(self):
        credentials2 = {
            'email':"none@none.com",
            "password": "password1@212"
        }
        response=self.jwt_obtain(credentials2)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data['detail'], 'No active account found with the given credentials')

    """
    Checks that an user without inv_code should not be able to obtain jwt
    """
    def test_jwt_obtain_user_without_inv_code(self):
        user_data2 = {
            'username':"username2",
            'email':"email2@test.com",
            "password": "password1@212",
        }
        user = User.objects.create_user(**user_data2)
        user.set_password(user_data2['password'])
        user.save()
        credentials2={
            'email':"email2@test.com",
            "password": "password1@212",
        }
        response=self.jwt_obtain(credentials2)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('inv_code', response.data)
    
    """
    Checks that a wrong user email should not be able to get a code
    """
    def test_send_code_wrong_email(self):
        response=self.send_code("email_false@test.com")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    """
    Checks that a right user email (unverified) should be able to get a code
    """
    def test_send_code_right_email(self):
        response=self.send_code()
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    
    """
    Checks that requesting a second code at same time should not be right
    """
    def test_send_code_too_many_times(self):
        self.send_code()
        response=self.send_code()
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    """
    Checks that sending a wrong code should not modify the user as verified
    """
    def test_send_wrong_code(self):
        # Code generation first:
        self.send_code()
        response=self.verify_code('123')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        response=self.verify_code('123456')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'][0], 'Invalid code')

    """
    Checks that sending a right code should modify the user as verified
    """
    def test_send_wrong_code(self):
        # Code generation first:
        self.send_code()
        # Get enerated code
        code=User.objects.get(email=self.user_data['email']).code_sent
        response=self.verify_code(str(code))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    """
    Checks that sending an invalid code should not modify the user as verified
    """
    def test_send_invalid_code(self):
        # Code generation first:
        self.send_code()
        # Set code validity to 1 second
        settings.EMAIL_CODE_VALID = 0
        # Get generated code
        code=User.objects.get(email=self.user_data['email']).code_sent
        # Sleep for 2 seconds
        time.sleep(2)
        # Verify invalid code
        response=self.verify_code(str(code))
        # Undo changes
        settings.EMAIL_CODE_VALID = 120
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'][0], 'Code is no longer valid')

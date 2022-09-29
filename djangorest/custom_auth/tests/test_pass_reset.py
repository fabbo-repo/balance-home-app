import time
import json
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from custom_auth.models import InvitationCode, User
import logging
from django.conf import settings

class PasswordResetTests(APITestCase):
    def setUp(self):
        # Avoid WARNING logs while testing wrong requests 
        logging.disable(logging.WARNING)

        self.reset_password_url=reverse('reset_password')
        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.user_get_del_url=reverse('user_put_get_del')

        # Create InvitationCode
        self.inv_code = InvitationCode.objects.create()
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
    
    def send_code(self) :
        return self.client.get(self.reset_password_url)
    
    def verify_code_password(self, code, password) :
        return self.client.post(
            self.reset_password_url,
            data=json.dumps(
                {
                    "new_password":password,
                    "code":code
                }),
            content_type="application/json"
        )


    """
    Checks that password reset code is sent
    """
    def test_send_password_reset_code(self):
        response=self.send_code()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user=User.objects.get(email=self.user_data["email"])
        self.assertIsNotNone(user.pass_reset)

    """
    Checks that password reset code is verified
    """
    def test_verify_password_reset_code(self):
        self.send_code()
        user=User.objects.get(email=self.user_data["email"])
        code = user.pass_reset
        response=self.verify_code_password(code, "password1@214")
        self.assertEqual(response.status_code, status.HTTP_200_OK,
            "Code verfication")
        self.credentials["password"] = "password1@214"
        response = self.jwt_obtain()
        self.assertEqual(response.status_code, status.HTTP_200_OK,
            "Jwt obtain")
    
    """
    Checks that password reset code is verified with same old password
    """
    def test_verify_old_password_reset(self):
        self.send_code()
        user=User.objects.get(email=self.user_data["email"])
        code = user.pass_reset
        response=self.verify_code_password(code, self.user_data["username"])
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    """
    Checks that sending a wrong password reset code should let change password
    """
    def test_send_wrong_code(self):
        # Code generation first:
        self.send_code()
        response=self.verify_code_password('123', self.user_data["username"])
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        response=self.verify_code_password('123456', self.user_data["username"])
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'][0], 'Invalid code')

    """
    Checks that sending an invalid code should not modify the user as verified
    """
    def test_send_invalid_code(self):
        # Code generation first:
        self.send_code()
        # Set code validity to 1 second
        settings.EMAIL_CODE_VALID = 0
        # Get generated code
        code=User.objects.get(email=self.user_data['email']).pass_reset
        # Sleep for 2 seconds
        time.sleep(2)
        # Verify invalid code
        response=self.verify_code_password(str(code), self.user_data["username"])
        # Undo changes
        settings.EMAIL_CODE_VALID = 120
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['code'][0], 'Code is no longer valid')

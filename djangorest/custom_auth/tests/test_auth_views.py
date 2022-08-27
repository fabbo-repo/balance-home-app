from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse

class TestViews(APITestCase):
    def setUp(self):
        self.jwt_obtain_url=reverse('jwt_obtain_pair')
        self.jwt_refresh_url=reverse('jwt_refresh')
        self.register_url=reverse('register')

        self.user_data={
            'username':"username",
            'email':"email@test.com",
            "password": "password1@212"
        }
        return super().setUp()
    
    def test_creates_user(self):
        response=self.client.post(
            self.register_url,
            self.user_data
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_gives_descriptive_errors_on_register(self):
        response=self.client.post(self.register_url,{'email':self.user_data['email']})
        self.assertEqual(response.status_code,status.HTTP_400_BAD_REQUEST)

    def test_logins_user(self):
        user=self.register_user()
        response=self.client.post(self.login_url, {'email':user.email,'password':self.user_data['password']})
        self.assertEqual(response.status_code,status.HTTP_200_OK)
        self.assertIsInstance(response.data['token'],str)

    def test_gives_descriptive_errors_on_login(self):
        response=self.client.post(self.login_url, {'email':'test@site.com','password':self.user_data['password']})
        self.assertEqual(response.status_code,status.HTTP_401_UNAUTHORIZED)
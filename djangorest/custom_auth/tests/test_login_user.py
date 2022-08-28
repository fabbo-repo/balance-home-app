
"""
* Must try login an inactive user
* Must try login an inexistant user
* Must try login an unverified user
* Must try send wrong email code
* Must try send invalid code
* Must try resend code

    def test_logins_user(self):
        user=self.register_user()
        response=self.client.post(self.login_url, {'email':user.email,'password':self.user_data['password']})
        self.assertEqual(response.status_code,status.HTTP_200_OK)
        self.assertIsInstance(response.data['token'],str)

    def test_gives_descriptive_errors_on_login(self):
        response=self.client.post(self.login_url, {'email':'test@site.com','password':self.user_data['password']})
        self.assertEqual(response.status_code,status.HTTP_401_UNAUTHORIZED)
        """
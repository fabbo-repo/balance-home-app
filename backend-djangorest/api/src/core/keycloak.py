from mozilla_django_oidc.auth import OIDCAuthenticationBackend


class KeycloakOIDCAuthenticationBackend(OIDCAuthenticationBackend):

    def create_user(self, claims):
        """ Overrides Authentication Backend so that Django users are
            created with the keycloak preferred_username.
            If nothing found matching the email, then try the username.
        """
        user = super(KeycloakOIDCAuthenticationBackend,
                     self).create_user(claims)
        user.first_name = claims.get('given_name', '')
        user.last_name = claims.get('family_name', '')
        user.email = claims.get('email')
        user.username = claims.get('preferred_username')
        user.save()
        return user

    def filter_users_by_claims(self, claims):
        """ Return all users matching the specified email.
            If nothing found matching the email, then try the username
        """
        email = claims.get('email')
        preferred_username = claims.get('preferred_username')

        if not email:
            return self.UserModel.objects.none()
        users = self.UserModel.objects.filter(email__iexact=email)

        if len(users) < 1:
            if not preferred_username:
                return self.UserModel.objects.none()
            users = self.UserModel.objects.filter(
                username__iexact=preferred_username)
        return users

    def update_user(self, user, claims):
        user.first_name = claims.get('given_name', '')
        user.last_name = claims.get('family_name', '')
        user.email = claims.get('email')
        user.username = claims.get('preferred_username')
        user.save()
        return user

from rest_framework import exceptions, authentication
from django.utils.translation import gettext_lazy as _
from keycloak.django_client import get_keycloak_client


class KeycloakAuthentication(authentication.BaseAuthentication):
    def get_access_token(self, request):
        """
        Get `access_token` str based on a request.

        Returns `None` if no authentication details were provided.
        """
        header = authentication.get_authorization_header(request)
        if not header:
            return None
        header = header.decode(authentication.HTTP_HEADER_ENCODING)

        auth = header.split()

        if len(auth) != 2 or auth[0].lower() != "bearer":
            raise exceptions.AuthenticationFailed(
                _("Unprocessable authorization header"))
        return auth[1]

    def authenticate(self, request):
        keycloak_client = get_keycloak_client()
        is_valid, data = keycloak_client.verify_access_token(
            self.get_access_token(request))
        if is_valid:
            # TODO create base user if not exists
            return (user, None)
        else:
            raise exceptions.AuthenticationFailed(_("Invalid access token"))

    def authenticate_header(self, request):
        return _("Bearer <jwt>")

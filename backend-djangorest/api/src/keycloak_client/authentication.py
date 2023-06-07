from rest_framework import exceptions, authentication
from django.utils.translation import gettext_lazy as _
from keycloak_client.django_client import get_keycloak_client
from custom_auth.models import User
from django.core.exceptions import ObjectDoesNotExist


class KeycloakAuthentication(authentication.BaseAuthentication):
    def get_access_token(self, request) -> str:
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
                _("Unprocessable authorization header")
            )
        return auth[1]

    def authenticate(self, request):
        keycloak_client = get_keycloak_client()
        access_token = self.get_access_token(request)
        if not access_token:
            return None
        is_valid, data = keycloak_client.verify_access_token(access_token)
        print(data)
        if is_valid:
            email = data.get("email")
            if email:
                try:
                    user = User.objects.get(email=email)
                    # TODO: check invitation code
                    return (user, None)
                except ObjectDoesNotExist:
                    raise exceptions.AuthenticationFailed(
                        _("User does not exists"))
        raise exceptions.AuthenticationFailed(_("Invalid access token"))

    def authenticate_header(self, request):
        return _("Bearer <jwt>")

"""
Provides a Keycloak authentication backend class for django rest framework.
"""
from app_auth.models import User
from rest_framework import exceptions, authentication
from django.utils.translation import gettext_lazy as _
from django.core.exceptions import ObjectDoesNotExist
from keycloak_client.django_client import get_keycloak_client


class KeycloakAuthentication(authentication.BaseAuthentication):
    """Keycloak rest authentication backend."""

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
        if is_valid:
            if "sub" in data:
                try:
                    user = User.objects.get(keycloak_id=data["sub"])
                    if not user.inv_code:
                        raise exceptions.AuthenticationFailed(
                            _("No invitation code stored")
                        )
                    return (user, None)
                except ObjectDoesNotExist as exc:
                    raise exceptions.AuthenticationFailed(
                        _("User does not exists")) from exc
        raise exceptions.AuthenticationFailed(_("Invalid access token"))

    def authenticate_header(self, request):
        return _("Bearer <jwt>")

from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.utils.translation import gettext_lazy as _
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.state import token_backend
from django.contrib.auth import get_user_model
from custom_auth.exceptions import (
    NoInvitationCodeException,
    UnverifiedEmailException,
    InvalidRefreshTokenException,
    InvalidCredentialsException
)


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):

    @classmethod
    def get_token(cls, user):
        if not user.inv_code:
            raise NoInvitationCodeException()
        if not user.verified:
            raise UnverifiedEmailException()
        token = super(CustomTokenObtainPairSerializer, cls).get_token(user)
        # Custom keys added in PAYLOAD
        token['username'] = user.username
        token['email'] = user.email
        return token


class CustomTokenRefreshSerializer(TokenRefreshSerializer):
    """
    Inherit from `TokenRefreshSerializer` and touch the database
    before re-issuing a new access token and ensure that the user
    exists and is active.
    """

    def validate(self, attrs):
        try:
            token_payload = token_backend.decode(attrs['refresh'])
        except:
            raise InvalidRefreshTokenException()
        try:
            user = get_user_model().objects.get(pk=token_payload['user_id'])
        except get_user_model().DoesNotExist:
            raise InvalidCredentialsException()
        if not user.is_active:
            raise InvalidCredentialsException()
        return super().validate(attrs)

from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.utils.translation import gettext_lazy as _
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.state import token_backend
from django.contrib.auth import get_user_model


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):

    @classmethod
    def get_token(cls, user):
        if not user.inv_code:
            raise serializers.ValidationError(
                {"inv_code": _("No invitation code stored")})
        if not user.verified:
            raise serializers.ValidationError(
                {"verified": _("Unverified email")})
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

    error_msg = _('No active account found with the given credentials')

    def validate(self, attrs):
        try:
            token_payload = token_backend.decode(attrs['refresh'])
        except:
            raise serializers.ValidationError(
                {"inavlid_token": _('Invalid refresh token')})
        try:
            user = get_user_model().objects.get(pk=token_payload['user_id'])
        except get_user_model().DoesNotExist:
            raise serializers.ValidationError(
                {"no_active_account": self.error_msg})
        if not user.is_active:
            raise serializers.ValidationError(
                {"no_active_account": self.error_msg})
        return super().validate(attrs)
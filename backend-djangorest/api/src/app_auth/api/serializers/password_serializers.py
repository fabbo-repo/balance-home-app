"""
Provide serializer classes.
"""
from rest_framework import serializers
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.password_validation import validate_password
from app_auth.exceptions import (
    NewOldPasswordException,
)


class ResetPasswordSerializer(serializers.Serializer):  # pylint: disable=abstract-method
    """
    Serializer for password reset (code creation)
    """
    email = serializers.EmailField(required=True)


class ChangePasswordSerializer(serializers.Serializer):  # pylint: disable=abstract-method
    """
    Serializer for password change (needs old password)
    """
    old_password = serializers.CharField(
        required=True,
        # No validation needed for old password
        # validators=[validate_password]
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )

    def validate(self, attrs):
        if attrs["old_password"] == attrs["new_password"]:
            raise NewOldPasswordException()
        return attrs

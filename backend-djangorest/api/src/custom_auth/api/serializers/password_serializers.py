from rest_framework import serializers
from django.utils.timezone import now
from custom_auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext_lazy as _
from rest_framework.serializers import ValidationError
from django.db import transaction
from custom_auth.exceptions import (
    ResetPasswordRetriesException,
    NewOldPasswordException,
    NewPasswordUserDataException,
)


class ResetPasswordSerializer(serializers.Serializer):
    """
    Serializer for password reset (code creation)
    """
    email = serializers.EmailField(required=True)

    def validate_email(self, email):
        try:
            User.objects.get(email=email)
        except User.DoesNotExist:
            raise ValidationError(_("User not found"))
        return email

    def validate(self, data):
        user = User.objects.get(email=data['email'])
        if user.date_pass_reset:
            duration_s = (now() - user.date_pass_reset).total_seconds()
            if duration_s <= 24 * 60 * 60 and user.count_pass_reset > 3:
                raise ResetPasswordRetriesException()
            user.save()
        return data


class ChangePasswordSerializer(serializers.Serializer):
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

    def validate_old_password(self, old_password):
        user = self.context["request"].user
        if not user.check_password(old_password):
            raise ValidationError(_("Invalid old password"))
        return old_password

    def validate(self, attrs):
        if attrs['old_password'] == attrs['new_password']:
            raise NewOldPasswordException()
        user = self.context["request"].user
        if user.username == attrs['new_password'] \
                or user.email == attrs['new_password']:
            raise NewPasswordUserDataException()
        return attrs

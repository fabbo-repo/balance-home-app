"""
Provide serializer classes.
"""
from rest_framework import serializers
from rest_framework.serializers import ValidationError
from django.core.validators import RegexValidator
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.auth.password_validation import validate_password
from django.utils.translation import check_for_language, gettext_lazy as _
from app_auth.models import InvitationCode, User
from app_auth.api.serializers.utils import check_username_pass
from app_auth.exceptions import (
    SameUsernameEmailException,
)


class UserCreationSerializer(serializers.ModelSerializer):
    """
    Serializer for User creation (register)
    """

    username = serializers.CharField(
        required=True,
        max_length=15,
        validators=[RegexValidator(regex=r"^[A-Za-z0-9]+$")],
    )
    email = serializers.EmailField(required=True)
    locale = serializers.CharField(
        max_length=5,
        required=True
    )
    inv_code = serializers.SlugRelatedField(
        required=True,
        slug_field="code",
        many=False,
        queryset=InvitationCode.objects.all(),  # pylint: disable=no-member
    )
    password = serializers.CharField(
        required=True, write_only=True, max_length=30, validators=[validate_password]
    )

    class Meta:  # pylint: disable=missing-class-docstring too-few-public-methods
        model = User
        fields = [
            "username",
            "email",
            "expected_annual_balance",  # not required
            "expected_monthly_balance",  # not required
            "locale",
            "inv_code",
            "pref_currency_type",
            "password",
        ]
        extra_kwargs = {
            "pref_currency_type": {"required": True}
        }

    def validate_locale(self, locale):
        """
        Validate locale param.
        """
        if not check_for_language(locale):
            raise ValidationError(_("Locale not supported"))
        return locale

    def validate_inv_code(self, code):
        """
        Validate invitation code param.
        """
        try:
            inv_code = InvitationCode.objects.get(  # pylint: disable=no-member
                code=str(code))
        except ObjectDoesNotExist as exc:
            raise ValidationError(_("Invitation code not found")) from exc
        if not inv_code.is_active:
            raise ValidationError(_("Invalid invitation code"))
        return code

    def validate(self, attrs):
        check_username_pass(
            attrs["username"], attrs["email"], attrs["password"]
        )
        if attrs["username"] == attrs["email"]:
            raise SameUsernameEmailException()
        return attrs


class UserRetrieveUpdateDestroySerializer(serializers.ModelSerializer):
    """
    Serializer to get, update or delete user data
    """

    username = serializers.CharField(
        required=False,
        max_length=15,
        validators=[RegexValidator(regex=r"^[A-Za-z0-9]+$")],
        write_only=True
    )
    locale = serializers.CharField(
        max_length=5,
        required=False,
        write_only=True
    )

    class Meta:  # pylint: disable=missing-class-docstring too-few-public-methods
        model = User
        fields = [
            "username",
            "receive_email_balance",
            "balance",
            "expected_annual_balance",
            "expected_monthly_balance",
            "receive_email_balance",
            "locale",
            "pref_currency_type",
            "image",
            "last_login",
        ]
        read_only_fields = [
            "last_login",
        ]

    def validate_locale(self, locale):
        """
        Validate locale param.
        """
        if not check_for_language(locale):
            raise ValidationError(_("Locale not supported"))
        return locale


class SendVerifyEmailSerializer(serializers.Serializer):  # pylint: disable=abstract-method
    """
    Serializer to send verification email
    """

    email = serializers.EmailField(
        required=True
    )

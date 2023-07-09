"""
Provide serializer classes.
"""
from rest_framework import serializers
from rest_framework.serializers import ValidationError
from django.core.validators import RegexValidator
from django.core.exceptions import ObjectDoesNotExist
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils.translation import check_for_language, gettext_lazy as _
from app_auth.models import InvitationCode, User
from app_auth.api.serializers.utils import check_username_pass
from app_auth.exceptions import (
    SameUsernameEmailException,
    UserEmailConflictException,
    CannotCreateUserException
)
from keycloak_client.django_client import get_keycloak_client


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

    @transaction.atomic
    def create(self, validated_data):
        inv_code = validated_data["inv_code"]
        pref_currency_type = validated_data["pref_currency_type"]
        keycloak_client = get_keycloak_client()
        created, res_code = keycloak_client.create_user(
            email=validated_data["email"],
            username=validated_data["username"],
            password=validated_data["password"],
            locale=validated_data["locale"]
        )
        if not created:
            if res_code == 409:
                raise UserEmailConflictException()
            raise CannotCreateUserException()
        user = User.objects.create(
            inv_code=inv_code,
            pref_currency_type=pref_currency_type
        )
        user.set_password(validated_data["password"])
        # Invitation code decrease, race condition
        inv_codes = InvitationCode.objects.select_for_update().filter(  # pylint: disable=no-member
            code=inv_code.code
        )
        for inv_code in inv_codes:
            inv_code.usage_left = inv_code.usage_left - 1
            if inv_code.usage_left <= 0:
                inv_code.is_active = False
            inv_code.save()
        # Alternative:
        # inv_code.usage_left = F('usage_left') - 1
        user.save()
        return user


class UserRetrieveUpdateDestroySerializer(serializers.ModelSerializer):
    """
    Serializer to get, update or delete user data
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

    class Meta:  # pylint: disable=missing-class-docstring too-few-public-methods
        model = User
        fields = [
            "username",
            "email",
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
            "last_login" "email",
        ]

    def validate_locale(self, locale):
        """
        Validate locale param.
        """
        if not check_for_language(locale):
            raise ValidationError(_("Locale not supported"))
        return locale

    # TODO retrieve username, email and language in keycloak

    @transaction.atomic
    def update(self, instance, validated_data):
        # TODO update username and language in keycloak
        super().update(instance, validated_data)

    # TODO delete keycloak user after removing app user (in case of error rollback transaction)
from rest_framework import serializers
from custom_auth.models import InvitationCode, User
from django.core.validators import RegexValidator
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils.translation import gettext_lazy as _
from django.utils.translation import check_for_language
from rest_framework.serializers import ValidationError
from custom_auth.api.serializers.utils import check_username_pass
from custom_auth.exceptions import (
    SameUsernameEmailException,
    UserEmailConflictException,
    CannotCreateUserException
)
from keycloak_client.django_client import get_keycloak_client
from django.core.exceptions import ObjectDoesNotExist



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
        queryset=InvitationCode.objects.all(),
    )
    password = serializers.CharField(
        required=True, write_only=True, max_length=30, validators=[validate_password]
    )

    class Meta:
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
        if not check_for_language(locale):
            raise ValidationError(_("Locale not supported"))
        return locale

    def validate_inv_code(self, code):
        try:
            inv_code = InvitationCode.objects.get(code=str(code))
        except ObjectDoesNotExist:
            raise ValidationError(_("Invitation code not found"))
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
        inv_codes = InvitationCode.objects.select_for_update().filter(
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

    class Meta:
        model = User
        fields = [
            "username",
            "email",
            "receive_email_balance",
            "balance",
            "expected_annual_balance",
            "expected_monthly_balance",
            "receive_email_balance",
            "language",
            "pref_currency_type",
            "image",
            "last_login",
        ]
        read_only_fields = [
            "last_login" "email",
        ]

    def update(self, instance, validated_data):
        super().update(instance, validated_data)
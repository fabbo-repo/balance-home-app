from rest_framework import serializers
from custom_auth.models import InvitationCode, User
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils.translation import gettext_lazy as _
from django.utils.translation import check_for_language
from rest_framework.serializers import ValidationError
from custom_auth.api.serializers.utils import check_username_pass12
from custom_auth.exceptions import (
    SameUsernameEmailException,
)


class UserCreationSerializer(serializers.ModelSerializer):
    """
    Serializer for User creation (register)
    """
    username = serializers.CharField(
        required=True,
        max_length=15,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    email = serializers.EmailField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    inv_code = serializers.SlugRelatedField(
        required=True,
        slug_field="code",
        many=False,
        queryset=InvitationCode.objects.all()
    )
    password = serializers.CharField(
        required=True,
        write_only=True,
        max_length=30,
        validators=[validate_password]
    )
    password2 = serializers.CharField(
        required=True,
        write_only=True,
    )

    class Meta:
        model = User
        fields = [
            'username',
            'email',
            'expected_annual_balance',  # not required
            'expected_monthly_balance',  # not required
            'language',
            'inv_code',
            'pref_currency_type',
            'password',
            'password2'
        ]
        extra_kwargs = {
            "pref_currency_type": {"required": True},
            "language": {"required": True}
        }

    def validate_language(self, lang):
        if not check_for_language(lang):
            raise ValidationError(_("Language not supported"))
        return lang

    def validate_inv_code(self, code):
        try:
            inv_code = InvitationCode.objects.get(code=str(code))
        except Exception as ex:
            print(ex)
            raise ValidationError(_("Invitation code not found"))
        if not inv_code.is_active:
            raise ValidationError(_("Invalid invitation code"))
        return code

    def validate(self, attrs):
        check_username_pass12(attrs['username'], attrs['email'],
                              attrs['password'], attrs['password2'])
        if attrs['username'] == attrs['email']:
            raise SameUsernameEmailException()
        return attrs

    def create(self, validated_data):
        inv_code = validated_data['inv_code']
        pref_currency_type = validated_data['pref_currency_type']
        language = validated_data['language']
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
            inv_code=inv_code,
            pref_currency_type=pref_currency_type,
            language=language
        )
        user.set_password(validated_data['password'])
        # Invitation code decrease, race condition
        inv_codes = InvitationCode.objects.select_for_update().filter(code=inv_code.code)
        with transaction.atomic():
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
        max_length=15,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )

    class Meta:
        model = User
        fields = [
            'username',
            'email',
            'receive_email_balance',
            'balance',
            'expected_annual_balance',
            'expected_monthly_balance',
            'receive_email_balance',
            'language',
            'pref_currency_type',
            'image',
            'last_login'
        ]
        read_only_fields = [
            'last_login'
            'email',
        ]

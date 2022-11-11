from rest_framework import serializers
from custom_auth.models import InvitationCode, User
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils.translation import gettext_lazy as _
from django.utils.translation import check_for_language
from django.core.exceptions import ValidationError


def check_inv_code(code):
    """
    Checks if an invitation code is created and valid
    """
    inv_code = None
    try: inv_code = InvitationCode.objects.get(code=code)
    except: raise serializers.ValidationError(_("Invitation code not found"))
    if not inv_code.is_active:
        raise serializers.ValidationError(_("Invalid invitation code"))

def check_username_pass12(username, email, password1, password2):
    """
    Checks if 2 passwords are different, also that username and email 
    are different to the passwords
    """
    if password1 != password2:
        raise serializers.ValidationError(
            {"password": _("Password fields do not match")})
    if username == password1 or email == password1:
        raise serializers.ValidationError(
            {"password": _("Password cannot match other profile data")})


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
            'language',
            'inv_code',
            'pref_coin_type',
            'password',
            'password2'
        ]
        extra_kwargs = {
            "pref_coin_type": {"required": True},
            "language": {"required": True}
        }

    def validate_language(self, value):
        if not check_for_language(value):
            raise serializers.ValidationError(
                _("Language not supported"))
        return value

    def validate_inv_code(self, value):
        check_inv_code(value.code)
        return value

    def validate(self, attrs):
        check_username_pass12(attrs['username'], attrs['email'], 
            attrs['password'], attrs['password2'])
        if attrs['username'] == attrs['email']:
            raise ValidationError(
                {'common_fields': _("Username and email can not be the same")})
        return attrs

    def create(self, validated_data):
        inv_code = validated_data['inv_code']
        pref_coin_type = validated_data['pref_coin_type']
        language = validated_data['language']
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
            inv_code=inv_code,
            pref_coin_type=pref_coin_type,
            language=language
        )
        user.set_password(validated_data['password'])
        # Invitation code decrease, race condition
        inv_codes = InvitationCode.objects.select_for_update().filter(code=inv_code.code)
        with transaction.atomic():
            for inv_code in inv_codes:
                inv_code.usage_left = inv_code.usage_left - 1
                if inv_code.usage_left <= 0: inv_code.is_active = False
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
    email = serializers.EmailField(
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
            'pref_coin_type',
            'image', 
            'last_login'
        ]
        read_only_fields = [
            'last_login'
        ]
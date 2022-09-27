from rest_framework import serializers
from custom_auth.models import InvitationCode, User
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils.timezone import now
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from django.utils.translation import check_for_language
from django.core.exceptions import ValidationError
from coin.currency_converter_integration import convert_or_fetch


"""
Race condition at usage left update in an InvitationCode
"""
@transaction.atomic()
def decrease_inv_code_usage(code):
    sid = transaction.savepoint()
    inv_code = code
    inv_code.usage_left -= 1
    if inv_code.usage_left <= 0: inv_code.is_active = False
    inv_code.save()
    transaction.savepoint_commit(sid)

"""
Checks if an invitation code is created and valid
"""
def check_inv_code(code):
    inv_code = None
    try: inv_code = InvitationCode.objects.get(code=code)
    except: raise serializers.ValidationError(_("Invitation code not found"))
    if not inv_code.is_active:
        raise serializers.ValidationError(_("Invalid invitation code"))

"""
Checks if 2 passwords are different, also that username and email 
are different to the passwords
"""
def check_username_pass12(username, email, password1, password2):
    if password1 != password2:
        raise serializers.ValidationError(
            {"password": _("Password fields do not match")})
    if username == password1 or email == password1:
        raise serializers.ValidationError(
            {"password": _("Password cannot match other profile data")})


"""
Serializer for User creation (register)
"""
class UserCreationSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        required=True, max_length=15,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    email = serializers.EmailField(
        required=True, 
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    inv_code = serializers.SlugRelatedField(
        required=True, 
        slug_field="code", many=False,
        queryset=InvitationCode.objects.all()
    )
    password = serializers.CharField(
        required=True, 
        write_only=True,
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
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
            inv_code=inv_code
        )
        user.set_password(validated_data['password'])
        decrease_inv_code_usage(inv_code)
        user.save()
        return user


"""
Serializer to get, update or delete user data
"""
class UserRetrieveUpdateDestroySerializer(serializers.ModelSerializer):
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
            'last_annual_balance', 
            'expected_monthly_balance', 
            'last_monthly_balance',
            'receive_email_balance', 
            'language',
            'pref_coin_type',
            'image', 
            'last_login'
        ]
        read_only_fields = [
            'balance',
            'last_annual_balance', 
            'last_monthly_balance',
            'last_login'
        ]

    def update(self, instance, validated_data):
        if 'email' in validated_data:
            validated_data['verified'] = False
        if 'pref_coin_type' in validated_data:
            convert_or_fetch(
                instance.pref_coin_type, 
                validated_data['pref_coin_type'],
                instance.balance
            )
        return super(UserRetrieveUpdateDestroySerializer, self).update(instance, validated_data)


"""
Serializer for password change (needs old password)
"""
class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(
        required=True,
        #validators=[validate_password]
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )

"""
Serializer for password reset (code verification)
"""
class ResetPasswordSerializer(serializers.Serializer):
    code = serializers.CharField(
        required=True, 
        min_length=6, max_length=6
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )

    def validate_code(self, code):
        user = self.user
        if not user.date_pass_reset:
            raise serializers.ValidationError("None code sent")
        if user.date_pass_reset:
            duration_s = (now() - user.date_pass_reset).total_seconds()
            if duration_s > settings.EMAIL_CODE_VALID :
                raise serializers.ValidationError(
                    _("Code is no longer valid"))
        if user.pass_reset != code :
            raise serializers.ValidationError(
                _("Invalid code"))
        return code

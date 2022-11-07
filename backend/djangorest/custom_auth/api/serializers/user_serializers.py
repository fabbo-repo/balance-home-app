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


@transaction.atomic()
def decrease_inv_code_usage(code):
    """
    Race condition at usage left update in an InvitationCode
    """
    sid = transaction.savepoint()
    inv_code = code
    inv_code.usage_left -= 1
    if inv_code.usage_left <= 0: inv_code.is_active = False
    inv_code.save()
    transaction.savepoint_commit(sid)

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
        decrease_inv_code_usage(inv_code)
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


class ChangePasswordSerializer(serializers.Serializer):
    """
    Serializer for password change (needs old password)
    """
    old_password = serializers.CharField(
        required=True,
        #validators=[validate_password]
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )

class ResetPasswordStartSerializer(serializers.Serializer):
    """
    Serializer for password reset (code creation)
    """
    email = serializers.EmailField(required=True)
    
    def validate_email(self, email):
        try:
            User.objects.get(email=email)
        except:
            raise serializers.ValidationError(_("User not found"))
        return email

    def validate(self, data):
        user = User.objects.get(email=data['email'])
        if user.date_pass_reset:
            duration_s = (now() - user.date_pass_reset).total_seconds()
            if duration_s < settings.EMAIL_CODE_THRESHOLD :
                raise serializers.ValidationError(
                    {"code": _("Code has already been sent, wait {} seconds")
                        .format(str(settings.EMAIL_CODE_THRESHOLD-duration_s))})
        return data

class ResetPasswordVerifySerializer(serializers.Serializer):
    """
    Serializer for password reset (code verification)
    """
    email = serializers.EmailField(required=True)
    code = serializers.CharField(
        required=True, 
        min_length=6, max_length=6
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )
    
    def validate_email(self, email):
        try:
            User.objects.get(email=email)
        except:
            raise serializers.ValidationError(_("User not found"))
        return email

    def validate(self, data):
        user = User.objects.get(email=data["email"])
        code = data["code"]
        if not user.date_pass_reset:
            raise serializers.ValidationError({"code", _("No code sent")})
        if user.date_pass_reset:
            duration_s = (now() - user.date_pass_reset).total_seconds()
            if duration_s > settings.EMAIL_CODE_VALID :
                raise serializers.ValidationError(
                    {"code": _("Code is no longer valid")})
        if user.pass_reset != code :
            raise serializers.ValidationError(
                {"code": _("Invalid code")})
        return data
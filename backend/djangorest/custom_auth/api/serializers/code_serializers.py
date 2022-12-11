from rest_framework import serializers
from django.utils.translation import get_language
from django.utils.timezone import now
from django.conf import settings
from custom_auth.api.serializers.utils import check_user_with_email
from custom_auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.utils.translation import gettext_lazy as _
from custom_auth.tasks import send_email_code
import os


class CodeSerializer(serializers.Serializer):
    email = serializers.EmailField(
        required=True
    )

    def validate_email(self, value):
        check_user_with_email(value)
        return value
    
    def validate(self, data):
        user = User.objects.get(email=data.get('email'))
        if user.date_code_sent:
            duration_s = (now() - user.date_code_sent).total_seconds()
            if duration_s < settings.EMAIL_CODE_THRESHOLD :
                raise serializers.ValidationError(
                    {"code": _("Code has already been sent, wait {} seconds")
                        .format(str(settings.EMAIL_CODE_THRESHOLD-duration_s))})
        return data

    def create(self, validated_data):
        email = validated_data['email']
        # Random 6 character string:
        code = os.urandom(3).hex()
        user = User.objects.get(email=email)    
        user.code_sent = code
        user.date_code_sent = now()
        send_email_code.delay(code, email, get_language())
        user.save()
        return {'email':email}


class CodeVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField(
        required=True
    )
    code = serializers.CharField(
        required=True, 
        min_length=6, max_length=6
    )

    def validate_email(self, value):
        check_user_with_email(value)
        return value

    def validate(self, data):
        user = User.objects.get(email=data.get('email'))
        if not user.date_code_sent:
            raise serializers.ValidationError({"code": _("No code sent")})
        if user.date_code_sent:
            duration_s = (now() - user.date_code_sent).total_seconds()
            if duration_s > settings.EMAIL_CODE_VALID :
                raise serializers.ValidationError(
                    {"code": _("Code is no longer valid")})
        if user.code_sent != data.get('code') :
            raise serializers.ValidationError({"code": _("Invalid code")})
        return data

    def create(self, validated_data):
        email = validated_data['email']
        user = User.objects.get(email=email)
        user.verified = True
        user.save()
        return validated_data

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
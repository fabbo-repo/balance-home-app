from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from custom_auth.models import User
import os
from custom_auth.serializers.utils import check_user_with_email
from custom_auth.tasks import send_email_code
from django.utils.timezone import now
from django.conf import settings


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):

    @classmethod
    def get_token(cls, user):
        if not user.inv_code:
            raise serializers.ValidationError({"inv_code": "No InvitationCode stored"})
        if not user.verified:
            raise serializers.ValidationError({"verified": "Email is not verified"})
        token = super(CustomTokenObtainPairSerializer, cls).get_token(user)

        # Custom keys added in PAYLOAD
        token['username'] = user.username
        token['email'] = user.email
        return token


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
                raise serializers.ValidationError("Code has already been sent, wait "
                    +str(settings.EMAIL_CODE_THRESHOLD-duration_s))
        return data

    def create(self, validated_data):
        email = validated_data['email']
        # Random 6 character string:
        code = os.urandom(3).hex()
        user = User.objects.get(email=email)    
        user.code_sent = code
        user.date_code_sent = now()
        send_email_code.delay(code, email)
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
            raise serializers.ValidationError({"code": "None code sent"})
        if user.date_code_sent:
            duration_s = (now() - user.date_code_sent).total_seconds()
            if duration_s > settings.EMAIL_CODE_VALID :
                raise serializers.ValidationError(
                    {"code": "Code is no longer valid"})
        if user.code_sent != data.get('code') :
            raise serializers.ValidationError({"code": "Invalid code"})
        return data

    def create(self, validated_data):
        email = validated_data['email']
        user = User.objects.get(email=email)
        user.verified = True
        user.save()
        return validated_data

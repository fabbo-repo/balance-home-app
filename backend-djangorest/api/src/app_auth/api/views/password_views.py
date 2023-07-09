from core.permissions import IsCurrentVerifiedUser
from app_auth.models import User
from rest_framework import generics, status
from rest_framework.parsers import JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from app_auth.api.serializers.password_serializers import (
    ChangePasswordSerializer,
    ResetPasswordSerializer
)
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from django.db import transaction
from keycloak_client.django_client import get_keycloak_client


class ChangePasswordView(generics.CreateAPIView):
    """
    An endpoint for changing password
    """
    serializer_class = ChangePasswordSerializer
    permission_classes = (IsCurrentVerifiedUser,)
    parser_classes = (JSONParser,)

    def get_object(self, queryset=None):
        return self.request.user

    def create(self, request, *args, **kwargs):
        self.user = self.get_object()
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            email = serializer.data["email"]
            new_password = serializer.data["new_password"]
            keycloak_client = get_keycloak_client()
            keycloak_client.change_user_password(email, new_password)
            return Response({}, status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ResetPasswordView(generics.CreateAPIView):
    """
    An endpoint for password reset 
    """
    serializer_class = ResetPasswordSerializer
    permission_classes = (AllowAny,)
    parser_classes = (JSONParser,)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            email = serializer.data["email"]
            user = User.objects.get(email=email)
            with transaction.atomic():
                keycloak_client = get_keycloak_client()
                keycloak_client.send_verify_email(email)
                user.count_pass_reset = 1 if user.count_pass_reset == 3 \
                    else user.count_pass_reset + 1
                user.date_pass_reset = now()
                user.save()
            return Response({}, status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

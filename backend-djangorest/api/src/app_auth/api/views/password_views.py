from core.permissions import IsCurrentVerifiedUser
from rest_framework import generics, status
from rest_framework.parsers import JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from app_auth.models import User
from app_auth.api.serializers.password_serializers import (
    ChangePasswordSerializer,
    ResetPasswordSerializer,
)
from app_auth.exceptions import (
    NewPasswordUserDataException,
    WronOldPasswordException,
    CannotSendResetPasswordEmailException,
    UnverifiedEmailException,
    UserNotFoundException,
    ResetPasswordRetriesException,
    CannotChangePasswordException,
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

    def get_object(self, queryset=None):  # pylint: disable=unused-argument
        return self.request.user

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        user = self.request.user

        if serializer.is_valid():
            keycloak_client = get_keycloak_client()

            user_info = keycloak_client.get_user_info_by_id(
                keycloak_id=user.keycloak_id)
            email = user_info["username"]
            username = user_info["firstName"]
            old_password = serializer.validated_data["old_password"]
            new_password = serializer.validated_data["new_password"]

            if username == new_password \
                    or email == new_password:
                raise NewPasswordUserDataException()

            tokens = keycloak_client.authenticate_user(email, old_password)
            if not tokens:
                raise WronOldPasswordException()

            changed = keycloak_client.change_user_password(
                user.keycloak_id, new_password)

            if not changed:
                raise CannotChangePasswordException()

            return Response({}, status.HTTP_204_NO_CONTENT)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ResetPasswordView(generics.CreateAPIView):
    """
    An endpoint for password reset 
    """
    serializer_class = ResetPasswordSerializer
    permission_classes = (AllowAny,)
    parser_classes = (JSONParser,)

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data["email"]

            keycloak_client = get_keycloak_client()

            user_info = keycloak_client.get_user_info_by_email(
                email=email)
            if not user_info:
                raise UserNotFoundException()
            if not dict(user_info)["emailVerified"]:
                raise UnverifiedEmailException()

            keycloak_id = dict(user_info)["id"]

            user = User.objects.get(keycloak_id=keycloak_id)
            if user.date_pass_reset:
                duration_s = (now() - user.date_pass_reset).total_seconds()
                if duration_s <= 24 * 60 * 60 and user.count_pass_reset >= 3:
                    raise ResetPasswordRetriesException()
            user.count_pass_reset = 1 if user.count_pass_reset == 3 \
                else user.count_pass_reset + 1
            user.date_pass_reset = now()

            sent = keycloak_client.send_reset_password_email(
                keycloak_id=keycloak_id)

            if not sent:
                raise CannotSendResetPasswordEmailException()
            user.save()
            return Response({}, status.HTTP_204_NO_CONTENT)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

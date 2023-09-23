from rest_framework import generics, status
from rest_framework.parsers import JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from app_auth.models import User
from app_auth.api.serializers.user_serializers import (
    EmailSerializer
)
from app_auth.exceptions import (
    CannotSendResetPasswordEmailException,
    UnverifiedEmailException,
    UserNotFoundException,
    ResetPasswordRetriesException,
)
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from django.db import transaction
from keycloak_client.django_client import get_keycloak_client


class ResetPasswordView(generics.CreateAPIView):
    """
    An endpoint for password reset 
    """
    serializer_class = EmailSerializer
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

import os
from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from rest_framework import generics, status, mixins
from rest_framework.parsers import JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from custom_auth.api.serializers.code_serializers import (
    CodeSerializer, 
    CodeVerificationSerializer,
    ChangePasswordSerializer,
    ResetPasswordStartSerializer,
    ResetPasswordVerifySerializer,
)
from custom_auth.tasks import send_password_code
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from django.utils.translation import get_language


class CodeView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeSerializer
    parser_classes = (JSONParser,)

class CodeVerificationView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeVerificationSerializer
    parser_classes = (JSONParser,)

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
            self.user.set_password(serializer.data["new_password"])
            self.user.save()
            return Response({}, status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ResetPasswordStartView(generics.GenericAPIView, mixins.CreateModelMixin, 
    mixins.RetrieveModelMixin):
    """
    An endpoint for password reset start
    """
    serializer_class = ResetPasswordStartSerializer
    permission_classes = (AllowAny,)
    parser_classes = (JSONParser,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            code = os.urandom(3).hex()
            user = User.objects.get(email=serializer.data["email"])
            user.pass_reset = code
            user.date_pass_reset = now()
            send_password_code.delay(code, user.email, get_language())
            user.save()
            return Response({}, status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class ResetPasswordVerifyView(generics.GenericAPIView, mixins.CreateModelMixin, 
    mixins.RetrieveModelMixin):
    """
    An endpoint for password reset verify
    """
    serializer_class = ResetPasswordVerifySerializer
    permission_classes = (AllowAny,)
    parser_classes = (JSONParser,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = User.objects.get(email=serializer.data["email"])
            user.set_password(serializer.data["new_password"])
            user.save()
            return Response({}, status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
import os
from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from custom_auth.serializers.jwt_code_serializers import CodeSerializer, CodeVerificationSerializer, CustomTokenObtainPairSerializer
from rest_framework import generics, status, mixins
from rest_framework.parsers import FormParser, MultiPartParser, JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from custom_auth.serializers.user_serializers import (
    ChangePasswordSerializer,
    ResetPasswordSerializer,
    UserCreationSerializer,
    UserRetrieveUpdateDestroySerializer
)
from custom_auth.tasks import send_password_code
from django.utils.timezone import now

class UserCreationView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = UserCreationSerializer
    parser_classes = (FormParser, JSONParser,)

class UserRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    serializer_class = UserRetrieveUpdateDestroySerializer
    parser_classes = (MultiPartParser, FormParser, JSONParser)
    
    def get_object(self, queryset=None):
        return self.request.user

class CodeView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeSerializer
    parser_classes = (JSONParser,)

class CodeVerificationView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeVerificationSerializer
    parser_classes = (JSONParser,)

class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = CustomTokenObtainPairSerializer
    parser_classes = (JSONParser,)

"""
An endpoint for changing password
"""
class ChangePasswordView(generics.CreateAPIView):   
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
            return Response([], status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

"""
An endpoint for password reset
"""
class ResetPasswordView(generics.GenericAPIView, mixins.CreateModelMixin, mixins.RetrieveModelMixin):
    serializer_class = ResetPasswordSerializer
    permission_classes = (IsCurrentVerifiedUser,)
    parser_classes = (JSONParser,)

    def get_object(self, queryset=None):
        return self.request.user
    
    def get(self, request, *args, **kwargs):
        self.user = self.get_object()
        code = os.urandom(3).hex()
        self.user.pass_reset = code
        self.user.date_pass_reset = now()
        send_password_code.delay(code, self.user.email)
        self.user.save()
        return Response([], status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        self.user = self.get_object()
        serializer = self.get_serializer(data=request.data)
        serializer.user = self.user
        if serializer.is_valid():
            self.user.set_password(serializer.data["new_password"])
            self.user.save()
            return Response([], status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
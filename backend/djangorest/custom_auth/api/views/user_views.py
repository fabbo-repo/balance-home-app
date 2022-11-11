import os
from coin.currency_converter_integration import convert_or_fetch
from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from custom_auth.api.serializers.code_serializers import (
    CodeSerializer, 
    CodeVerificationSerializer, 
)
from rest_framework import generics, status, mixins
from rest_framework.parsers import FormParser, MultiPartParser, JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from custom_auth.api.serializers.user_serializers import (
    UserCreationSerializer,
    UserRetrieveUpdateDestroySerializer
)
from custom_auth.api.serializers.code_serializers import (
    ChangePasswordSerializer,
    ResetPasswordStartSerializer,
    ResetPasswordVerifySerializer,
)
from custom_auth.tasks import send_password_code
from django.utils.timezone import now
from django.utils.translation import gettext_lazy as _
from django.utils.translation import get_language

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
    
    def perform_update(self, serializer):
        if 'email' in serializer.validated_data:
            serializer.validated_data['verified'] = False
        # The user balance should only be converted if
        # the same balance is provided in the request
        # and the pref_coin_type is changed, same for
        # expected_annual_balance and expected_monthly_balance
        if 'pref_coin_type' in serializer.validated_data:
            if 'balance' in serializer.validated_data:
                serializer.validated_data['balance'] = convert_or_fetch(
                    serializer.instance.pref_coin_type, 
                    serializer.validated_data['pref_coin_type'],
                    serializer.validated_data['balance']
                )
            if 'expected_annual_balance' in serializer.validated_data:
                serializer.validated_data['expected_annual_balance'] = convert_or_fetch(
                    serializer.instance.pref_coin_type, 
                    serializer.validated_data['pref_coin_type'],
                    serializer.validated_data['expected_annual_balance']
                )
            if 'expected_monthly_balance' in serializer.validated_data:
                serializer.validated_data['expected_monthly_balance'] = convert_or_fetch(
                    serializer.instance.pref_coin_type, 
                    serializer.validated_data['pref_coin_type'],
                    serializer.validated_data['expected_monthly_balance']
                )
        serializer.save()

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
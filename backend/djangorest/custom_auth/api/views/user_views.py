from coin.currency_converter_integration import convert_or_fetch
from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from rest_framework import generics
from rest_framework.parsers import FormParser, MultiPartParser, JSONParser
from rest_framework.permissions import AllowAny
from custom_auth.api.serializers.user_serializers import (
    UserCreationSerializer,
    UserRetrieveUpdateDestroySerializer
)
from django.utils.translation import gettext_lazy as _

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
        # Email change is not allowed
        #if 'email' in serializer.validated_data:
        #    serializer.validated_data['verified'] = False
        
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
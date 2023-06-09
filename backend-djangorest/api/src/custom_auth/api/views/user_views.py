from coin.currency_converter_integration import convert_or_fetch
from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from rest_framework import generics
from rest_framework.response import Response
from rest_framework.parsers import FormParser, MultiPartParser, JSONParser
from rest_framework.permissions import AllowAny
from custom_auth.api.serializers.user_serializers import (
    UserCreationSerializer,
    UserRetrieveUpdateDestroySerializer
)
from django.utils.translation import gettext_lazy as _
from django.db import transaction
from django.utils.timezone import now
from custom_auth.tasks import change_converted_quantities
from rest_framework.serializers import ValidationError
from keycloak_client.django_client import get_keycloak_client


class UserCreationView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = UserCreationSerializer
    parser_classes = (FormParser, JSONParser,)

    def perform_create(self, serializer):
        with transaction.atomic():
            serializer.save()
            keycloak_client = get_keycloak_client()
            if not keycloak_client.create_user(
                email=serializer.validated_data["email"],
                username=serializer.validated_data["username"],
                password=serializer.validated_data["password"],
                locale=serializer.validated_data["locale"]
            ):
                # Throw exception
                pass


class UserRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    serializer_class = UserRetrieveUpdateDestroySerializer
    parser_classes = (MultiPartParser, FormParser, JSONParser)

    def get_object(self, queryset=None):
        return self.request.user

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        keycloak_client = get_keycloak_client()
        user_data = keycloak_client.get_user_info(
            keycloak_id=request.user.keycloak_id
        )
        last_login = keycloak_client.get_user_last_login(
            keycloak_id=request.user.keycloak_id
        )
        serializer.data["username"] = user_data["username"]
        serializer.data["email"] = user_data["email"]
        serializer.data["last_login"] = last_login
        serializer.data["locale"] = user_data["attributes"]["locale"]
        return Response(serializer.data)

    def perform_update(self, serializer):
        # The user balance should only be converted if
        # the same balance is provided in the request
        # and the pref_currency_type is changed, same for
        # expected_annual_balance and expected_monthly_balance
        with transaction.atomic():
            if (
                'pref_currency_type' in serializer.validated_data
                and serializer.validated_data["pref_currency_type"] != serializer.instance.pref_currency_type
            ):
                if 'balance' in serializer.validated_data:
                    user = self.request.user
                    if user.date_coin_change:
                        duration_s = (
                            now() - user.date_coin_change).total_seconds()
                        if duration_s < 24 * 60 * 60:
                            raise ValidationError(
                                {"pref_currency_type": _("Coin type has already been changed in the las 24 hours")})
                    serializer.validated_data['balance'] = convert_or_fetch(
                        serializer.instance.pref_currency_type,
                        serializer.validated_data['pref_currency_type'],
                        serializer.validated_data['balance']
                    )
                    # Change expected annual balance
                    if 'expected_annual_balance' not in serializer.validated_data:
                        serializer.validated_data['expected_annual_balance'] =\
                            self.request.user.expected_annual_balance
                    serializer.validated_data['expected_annual_balance'] = convert_or_fetch(
                        serializer.instance.pref_currency_type,
                        serializer.validated_data['pref_currency_type'],
                        serializer.validated_data['expected_annual_balance']
                    )
                    # Change expected monthly balance
                    if 'expected_monthly_balance' not in serializer.validated_data:
                        serializer.validated_data['expected_monthly_balance'] =\
                            self.request.user.expected_monthly_balance
                    serializer.validated_data['expected_monthly_balance'] = convert_or_fetch(
                        serializer.instance.pref_currency_type,
                        serializer.validated_data['pref_currency_type'],
                        serializer.validated_data['expected_monthly_balance']
                    )
                    change_converted_quantities.delay(
                        user.email,
                        user.pref_currency_type.code,
                        serializer.validated_data['pref_currency_type'].code
                    )
                    serializer.validated_data["date_coin_change"] = now()
                if 'expected_annual_balance' in serializer.validated_data:
                    serializer.validated_data['expected_annual_balance'] = convert_or_fetch(
                        serializer.instance.pref_currency_type,
                        serializer.validated_data['pref_currency_type'],
                        serializer.validated_data['expected_annual_balance']
                    )
                if 'expected_monthly_balance' in serializer.validated_data:
                    serializer.validated_data['expected_monthly_balance'] = convert_or_fetch(
                        serializer.instance.pref_currency_type,
                        serializer.validated_data['pref_currency_type'],
                        serializer.validated_data['expected_monthly_balance']
                    )
            serializer.save()
            # Keycloak update
            keycloak_client = get_keycloak_client()
            keycloak_client.update_user(
                keycloak_id=self.request.user.keycloak_id,
                username=serializer.validated_data.get("username"),
                locale=serializer.validated_data.get("locale")
            )

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.delete()
            keycloak_client = get_keycloak_client()
            keycloak_client.delete_user()

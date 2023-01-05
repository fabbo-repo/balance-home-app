from rest_framework import viewsets
from balance.utils import (
    check_dates_and_update_date_balances, 
    update_or_create_annual_balance, 
    update_or_create_monthly_balance
)
from revenue.models import Revenue, RevenueType
from revenue.api.serializers import (
    RevenueTypeSerializer,
    RevenuePostPutDelSerializer, 
    RevenueListDetailSerializer
)
from core.permissions import IsCurrentVerifiedUser
from rest_framework.permissions import IsAuthenticated
from revenue.api.filters import RevenueFilterSet
from rest_framework import generics
from coin.currency_converter_integration import convert_or_fetch
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework.response import Response
from datetime import date


class RevenueTypeRetrieveView(generics.RetrieveAPIView):
    queryset = RevenueType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = RevenueTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(RevenueTypeRetrieveView, self).get(request, *args, **kwargs)

class RevenueTypeListView(generics.ListAPIView):
    queryset = RevenueType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = RevenueTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(RevenueTypeListView, self).get(request, *args, **kwargs)


class RevenueView(viewsets.ModelViewSet):
    queryset = Revenue.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = RevenueFilterSet

    def get_queryset(self):
        """
        Filter objects by owner
        """
        if getattr(self, 'swagger_fake_view', False):
            return Revenue.objects.none()  # return empty queryset
        return Revenue.objects.filter(owner=self.request.user)
    
    def get_serializer_class(self):
        if self.request.method == 'GET':
            return RevenueListDetailSerializer
        return RevenuePostPutDelSerializer

    def perform_create(self, serializer):
        owner = self.request.user
        if serializer.validated_data.get('quantity'):
            coin_from = serializer.validated_data['coin_type']
            coin_to = owner.pref_coin_type
            amount = serializer.validated_data['quantity']
            coverted_quantity = convert_or_fetch(coin_from, coin_to, amount)
            owner.balance += coverted_quantity
            owner.balance = round(owner.balance, 2)
            owner.save()
            # Create AnnualBalance or update it
            update_or_create_annual_balance(
                coverted_quantity, owner,
                serializer.validated_data['date'].year, True
            )
            # Create MonthlyBalance or update it
            update_or_create_monthly_balance(
                coverted_quantity, owner,
                serializer.validated_data['date'].year,
                serializer.validated_data['date'].month, True
            )
        # Inject owner data to the serializer
        serializer.save(owner=owner)

    def perform_update(self, serializer):
        """
        In case there is a coin_type update without a quantity update
        the quantity will remains the same as before, so it wont be
        converted. Conversions will only be made if quantity is included
        with a coin_type change
        """
        owner = self.request.user
        # In case there is a quantity update
        if serializer.validated_data.get('quantity'):
            # In case coin_type is not changed, coin_from as the same
            if not serializer.validated_data.get('coin_type'):
                coin_from = serializer.instance.coin_type
            # In case coin_type is changed, coin_from is the new coin_type
            else: coin_from = serializer.validated_data['coin_type']
            coin_to = owner.pref_coin_type
            quantity = serializer.validated_data['quantity']
            converted_new_quantity = convert_or_fetch(
                coin_from, coin_to, quantity
            )
            converted_old_quantity = convert_or_fetch(
                serializer.instance.coin_type, coin_to, 
                serializer.instance.quantity
            )
            owner.balance += converted_new_quantity \
                - converted_old_quantity
            owner.balance = round(owner.balance, 2)
            owner.save()
            # Create DateBalance or update it
            check_dates_and_update_date_balances(
                serializer.instance, 
                converted_old_quantity,
                converted_new_quantity,
                serializer.validated_data.get('date')
            )
        # In case there is a change of date without quantity 
        # month and year needs to be checked
        elif serializer.validated_data.get('date'):
            coin_from = serializer.validated_data['coin_type'] \
                if serializer.validated_data.get('coin_type') \
                else serializer.instance.coin_type
            converted_quantity = convert_or_fetch(
                coin_from, owner.pref_coin_type, 
                serializer.instance.quantity
            )
            # Create DateBalance or update it
            check_dates_and_update_date_balances(
                serializer.instance, converted_quantity, None,
                serializer.validated_data['date']
            )
        serializer.save()

    def perform_destroy(self, instance):
        owner = self.request.user
        coin_to = owner.pref_coin_type
        converted_quantity = convert_or_fetch(
            instance.coin_type, coin_to, 
            instance.quantity
        )
        owner.balance -= converted_quantity
        owner.balance = round(owner.balance, 2)
        owner.save()
        # Create AnnualBalance or update it
        update_or_create_annual_balance(
            - converted_quantity, owner,
            instance.date.year, True
        )
        # Create MonthlyBalance or update it
        update_or_create_monthly_balance(
            - converted_quantity, owner,
            instance.date.year, instance.date.month, True
        )
        instance.delete()

class RevenueYearsRetrieveView(APIView):
    permission_classes = (IsCurrentVerifiedUser,)
    
    @method_decorator(cache_page(60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, format=None):
        """
        This view will be cached for 1 minute
        """
        revenues = list(Revenue.objects.all())
        if revenues:
            return Response(
                data={"years": list(set([
                    rev.date.year for rev in revenues
                ]))},
            )
        return Response(
            data={"years": [date.today().year]},
        )
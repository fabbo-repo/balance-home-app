from rest_framework import viewsets
from balance.utils import (
    check_dates_and_update_date_balances, 
    update_or_create_annual_balance, 
    update_or_create_monthly_balance
)
from expense.models import Expense, ExpenseType
from expense.api.serializers import (
    ExpenseTypeSerializer,
    ExpensePostPutDelSerializer,
    ExpenseListDetailSerializer
)
from core.permissions import IsCurrentVerifiedUser
from rest_framework.permissions import IsAuthenticated
from expense.api.filters import ExpenseFilterSet
from rest_framework import generics
from coin.currency_converter_integration import convert_or_fetch
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework.response import Response
from datetime import date
from django.db import transaction


class ExpenseTypeRetrieveView(generics.RetrieveAPIView):
    queryset = ExpenseType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ExpenseTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(ExpenseTypeRetrieveView, self).get(request, *args, **kwargs)

class ExpenseTypeListView(generics.ListAPIView):
    queryset = ExpenseType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ExpenseTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(ExpenseTypeListView, self).get(request, *args, **kwargs)


class ExpenseView(viewsets.ModelViewSet):
    queryset = Expense.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = ExpenseFilterSet

    def get_queryset(self):
        """
        Filter objects by owner
        """
        if getattr(self, 'swagger_fake_view', False):
            return Expense.objects.none()  # return empty queryset
        return Expense.objects.filter(owner=self.request.user)
    
    def get_serializer_class(self):
        if self.request.method == 'GET':
            return ExpenseListDetailSerializer
        return ExpensePostPutDelSerializer

    def perform_create(self, serializer):
        owner = self.request.user
        with transaction.atomic():
            # Change user balance according to real quantity
            if serializer.validated_data.get('real_quantity'):
                coin_from = serializer.validated_data['coin_type']
                coin_to = owner.pref_coin_type
                real_quantity = serializer.validated_data['real_quantity']
                converted_quantity = convert_or_fetch(coin_from, coin_to, real_quantity)
                serializer.validated_data['converted_quantity'] = converted_quantity
                owner.balance -= converted_quantity
                owner.balance = round(owner.balance, 2)
                owner.save()
                # Create AnnualBalance or update it
                update_or_create_annual_balance(
                    converted_quantity, owner,
                    serializer.validated_data['date'].year, False
                )
                # Create MonthlyBalance or update it
                update_or_create_monthly_balance(
                    converted_quantity, owner,
                    serializer.validated_data['date'].year,
                    serializer.validated_data['date'].month, False
                )
            # Inject owner data to the serializer
            serializer.save(owner=owner)

    def perform_update(self, serializer):
        owner = self.request.user
        with transaction.atomic():
        # In case there is a real quantity update
            if serializer.validated_data.get('real_quantity'):
                # In case coin_type is not changed, coin_from as the same
                if not serializer.validated_data.get('coin_type'):
                    coin_from = serializer.instance.coin_type
                # In case coin_type is changed, coin_from is the new coin_type
                else: coin_from = serializer.validated_data['coin_type']
                coin_to = owner.pref_coin_type
                real_quantity = serializer.validated_data['real_quantity']
                converted_quantity = convert_or_fetch(
                    coin_from, coin_to, real_quantity
                )
                serializer.validated_data['converted_quantity'] = converted_quantity
                converted_old_quantity = convert_or_fetch(
                    serializer.instance.coin_type, coin_to, 
                    serializer.instance.real_quantity
                )
                owner.balance -= converted_quantity \
                    - converted_old_quantity
                owner.balance = round(owner.balance, 2)
                owner.save()
                # Create DateBalance or update it
                check_dates_and_update_date_balances(
                    serializer.instance, 
                    converted_old_quantity,
                    converted_quantity,
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
                    serializer.instance.real_quantity
                )
                serializer.validated_data['converted_quantity'] = converted_quantity
                # Create DateBalance or update it
                check_dates_and_update_date_balances(
                    serializer.instance, converted_quantity, None,
                    serializer.validated_data['date']
                )
            # In case there is a coin_type update without a quantity update
            # the quantity will remains the same as before, so it wont be
            # converted
            serializer.save()

    def perform_destroy(self, instance):
        owner = self.request.user
        with transaction.atomic():
            coin_to = owner.pref_coin_type
            converted_quantity = convert_or_fetch(
                instance.coin_type, coin_to, 
                instance.real_quantity
            )
            owner.balance += converted_quantity
            owner.balance = round(owner.balance, 2)
            owner.save()
            # Create AnnualBalance or update it
            update_or_create_annual_balance(
                - converted_quantity, owner, 
                instance.date.year, False
            )
            # Create MonthlyBalance or update it
            update_or_create_monthly_balance(
                - converted_quantity, owner,
                instance.date.year, instance.date.month, False
            )
            instance.delete()

class EspenseYearsRetrieveView(APIView):
    permission_classes = (IsCurrentVerifiedUser,)
    
    @method_decorator(cache_page(60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, format=None):
        """
        This view will be cached for 1 minute
        """
        expenses = list(Expense.objects.all())
        if expenses:
            return Response(
                data={"years": list(set([
                    exp.date.year for exp in expenses
                ]))},
            )
        return Response(
            data={"years": [date.today().year]},
        )

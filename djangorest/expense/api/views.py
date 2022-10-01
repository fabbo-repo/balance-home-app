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


class ExpenseTypeRetrieveView(generics.RetrieveAPIView):
    queryset = ExpenseType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ExpenseTypeSerializer

class ExpenseTypeListView(generics.ListAPIView):
    queryset = ExpenseType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ExpenseTypeSerializer

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
        # Change user balance according to quantity
        if serializer.validated_data.get('quantity'):
            coin_from = serializer.validated_data['coin_type']
            coin_to = owner.pref_coin_type
            amount = serializer.validated_data['quantity']
            coverted_quantity = convert_or_fetch(coin_from, coin_to, amount)
            owner.balance -= coverted_quantity
            owner.balance = round(owner.balance, 2)
            owner.save()
            # Create AnnualBalance or update it
            update_or_create_annual_balance(
                coverted_quantity, owner,
                serializer.validated_data['date'].year, False
            )
            # Create MonthlyBalance or update it
            update_or_create_monthly_balance(
                coverted_quantity, owner,
                serializer.validated_data['date'].year,
                serializer.validated_data['date'].month, False
            )
        # Inject owner data to the serializer
        serializer.save(owner=owner)

    def perform_update(self, serializer):
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
            owner.balance -= converted_new_quantity \
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
        # In case there is a coin_type update without a quantity update
        # the quantity will remains the same as before, so it wont be
        # converted
        serializer.save()

    def perform_destroy(self, instance):
        owner = self.request.user
        coin_to = owner.pref_coin_type
        converted_quantity = convert_or_fetch(
            instance.coin_type, coin_to, 
            instance.quantity
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
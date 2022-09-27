from rest_framework import viewsets
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

    """
    Filter objects by owner
    """
    def get_queryset(self):
        if getattr(self, 'swagger_fake_view', False):
            return Expense.objects.none()  # return empty queryset
        return Expense.objects.filter(owner=self.request.user)
    
    def get_serializer_class(self):
        if self.request.method == 'GET':
            return ExpenseListDetailSerializer
        return ExpensePostPutDelSerializer

    def perform_create(self, serializer):
        owner = self.request.user
        if serializer.validated_data.get('quantity'):
            coin_from = serializer.validated_data['coin_type']
            coin_to = owner.pref_coin_type
            amount = serializer.validated_data['quantity']
            owner.balance -= \
                convert_or_fetch(coin_from, coin_to, amount)
            owner.save()
        # Inject owner data to the serializer
        serializer.save(owner=owner)

    def perform_update(self, serializer):
        owner = self.request.user
        if serializer.validated_data.get('quantity'):
            if not serializer.validated_data.get('coin_type'):
                coin_from = serializer.instance.coin_type
            else: coin_from = serializer.validated_data['coin_type']
            coin_to = owner.pref_coin_type
            amount = serializer.validated_data['quantity']
            owner.balance -= \
                convert_or_fetch(coin_from, coin_to, amount) \
                - convert_or_fetch(
                    serializer.instance.coin_type, coin_to, 
                    serializer.instance.quantity)
            owner.save()
        serializer.save()

    def perform_destroy(self, instance):
        owner = self.request.user
        coin_to = owner.pref_coin_type
        owner.balance += convert_or_fetch(
            instance.coin_type, coin_to, 
            instance.quantity)
        owner.save()
        instance.delete()
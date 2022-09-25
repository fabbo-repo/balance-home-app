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
        if serializer.validated_data.get('quantity'):
            self.request.user.balance -= \
                serializer.validated_data.get('quantity')
            self.request.user.save()
        # Inject owner data to the serializer
        serializer.save(owner=self.request.user)

    def perform_update(self, serializer):
        if serializer.validated_data.get('quantity'):
            self.request.user.balance -= \
                serializer.validated_data.get('quantity') \
                - serializer.instance.quantity
            self.request.user.save()
        serializer.save()

    def perform_destroy(self, instance):
        self.request.user.balance += instance.quantity
        self.request.user.save()
        instance.delete()
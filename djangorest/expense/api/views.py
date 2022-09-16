from rest_framework import viewsets
from expense.models import Expense
from expense.api.serializers import ExpenseSerializer
from core.permissions import IsCurrentVerifiedUser
from expense.filters import ExpenseFilterSet

class ExpenseView(viewsets.ModelViewSet):
    queryset = Expense.objects.all()
    serializer_class = ExpenseSerializer
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = ExpenseFilterSet

    """
    Filter objects by owner
    """
    def get_queryset(self):
        return Expense.objects.filter(owner=self.request.user)

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
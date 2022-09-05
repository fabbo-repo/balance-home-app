from rest_framework import viewsets
from expense.models import Expense
from expense.serializers import ExpenseSerializer
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

    """
    Inject owner data to the serializer
    """
    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
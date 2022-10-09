from rest_framework import viewsets
from balance.api.filter import AnnualBalanceFilterSet, MonthlyBalanceFilterSet
from balance.models import AnnualBalance, MonthlyBalance
from balance.api.serializers import AnnualBalanceSerializer, MonthlyBalanceSerializer
from core.permissions import IsCurrentVerifiedUser

class AnnualBalanceView(viewsets.ModelViewSet):
    queryset = AnnualBalance.objects.all()
    serializer_class = AnnualBalanceSerializer
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = AnnualBalanceFilterSet

    def get_queryset(self):
        """
        Filter objects by owner
        """
        if getattr(self, 'swagger_fake_view', False):
            return AnnualBalance.objects.none()  # return empty queryset
        return AnnualBalance.objects.filter(owner=self.request.user)


class MonthlyBalanceView(viewsets.ModelViewSet):
    queryset = MonthlyBalance.objects.all()
    serializer_class = MonthlyBalanceSerializer
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = MonthlyBalanceFilterSet

    def get_queryset(self):
        """
        Filter objects by owner
        """
        if getattr(self, 'swagger_fake_view', False):
            return MonthlyBalance.objects.none()  # return empty queryset
        return MonthlyBalance.objects.filter(owner=self.request.user)

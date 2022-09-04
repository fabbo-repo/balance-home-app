from rest_framework import viewsets
from revenue.models import Revenue
from revenue.serializers import RevenueSerializer
from core.permissions import IsCurrentVerifiedUser
from revenue.filters import RevenueFilterSet

class RevenueView(viewsets.ModelViewSet):
    queryset = Revenue.objects.all()
    serializer_class = RevenueSerializer
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = RevenueFilterSet

    """
    Filter objects by owner
    """
    def get_queryset(self):
        return Revenue.objects.filter(owner=self.request.user)

    """
    Inject owner data to the serializer
    """
    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
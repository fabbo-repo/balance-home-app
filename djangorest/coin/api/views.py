from coin.models import CoinType
from coin.api.serializers import CoinTypeSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics


class CoinTypeRetrieveView(generics.RetrieveAPIView):
    queryset = CoinType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = CoinTypeSerializer

class CoinTypeListView(generics.ListAPIView):
    queryset = CoinType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = CoinTypeSerializer

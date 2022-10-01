import json
from coin.models import CoinExchange, CoinType
from coin.api.serializers import CoinTypeSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils.translation import gettext_lazy as _
from django.utils import timezone

class CoinTypeRetrieveView(generics.RetrieveAPIView):
    queryset = CoinType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = CoinTypeSerializer

class CoinTypeListView(generics.ListAPIView):
    queryset = CoinType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = CoinTypeSerializer

class CoinExchangeRetrieveView(APIView):
    permission_classes = (IsAuthenticated,)
    
    def get(self, request, code, format=None):
        last_coin_exchange = CoinExchange.objects.last()
        if last_coin_exchange:
            exchange_data = last_coin_exchange.exchange_data
            json_data = json.loads(exchange_data)
            if code not in json_data:
                return Response(
                    data={"detail": _("{} code not supported").format(code)},
                    status=status.HTTP_400_BAD_REQUEST
                )
            return Response(
                data={"coin_exchange": json_data[code]},
            )
        return Response(
            data={"detail": _("No exchange data, try later")},
            status=status.HTTP_400_BAD_REQUEST
        )

class CoinExchangeListView(APIView):
    permission_classes = (IsAuthenticated,)
    
    def get(self, request, days, format=None):
        if days < 1: return Response(data={})
        if days > 30: days = 30
        data = CoinExchange.objects.filter(
            created__lte=timezone.now(), 
            created__gt=timezone.now() - timezone.timedelta(days=days)
        )
        return Response(
            data=[
                {
                    'echange': json.loads(x.exchange_data), 
                    'date': x.created.date()
                } for x in data
            ]
        )
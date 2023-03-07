import json
from coin.models import CoinExchange, CoinType
from coin.api.serializers import CoinTypeSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.utils.translation import gettext_lazy as _
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from rest_framework.permissions import AllowAny


class CoinTypeRetrieveView(generics.RetrieveAPIView):
    queryset = CoinType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = CoinTypeSerializer

    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(CoinTypeRetrieveView, self).get(request, *args, **kwargs)

class CoinTypeListView(generics.ListAPIView):
    queryset = CoinType.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = CoinTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(CoinTypeListView, self).get(request, *args, **kwargs)


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
                data={
                    "code": code,
                    "exchanges": [
                        { 
                            "code": exchange,
                            "value": json_data[code][exchange]
                        } for exchange in json_data[code].keys()
                    ]
                },
            )
        return Response(
            data={"detail": _("No exchange data, try later")},
            status=status.HTTP_400_BAD_REQUEST
        )

class CoinExchangeListView(APIView):
    permission_classes = (IsAuthenticated,)
    
    def get(self, request, days, format=None):
        if days < 1: return Response(data=[])
        if days > 30: days = 30
        data = CoinExchange.objects.filter(
            created__lte=timezone.now(), 
            created__gt=timezone.now() - timezone.timedelta(days=days)
        )
        return Response(
            data={
                "date_exchanges": [
                    {
                        'exchanges': [
                            {
                                "code": code,
                                "exchanges": [
                                    { 
                                        "code": exchange,
                                        "value": json.loads(x.exchange_data)[code][exchange]
                                    } for exchange in json.loads(x.exchange_data)[code].keys()
                                ]
                            } for code in json.loads(x.exchange_data).keys()
                        ], 
                        'date': x.created.date()
                    } for x in data
                ]
            }
        )
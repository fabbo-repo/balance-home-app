from rest_framework import serializers
from coin.models import CoinType, CoinExchange


class CoinTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinType
        fields = [
            'code'
        ]

class CoinExchangeSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinType
        fields = [
            'exchange_data',
            'created'
        ]
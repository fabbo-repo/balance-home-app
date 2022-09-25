from rest_framework import serializers
from coin.models import CoinType


class CoinTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoinType
        fields = [
            'code',
            'name',
            'exchange'
        ]
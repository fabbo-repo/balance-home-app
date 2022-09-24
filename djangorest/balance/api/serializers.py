from rest_framework import serializers
from balance.models import AnnualBalance, MonthlyBalance


class AnnualBalanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnnualBalance
        fields = [
            'gross_quantity',
            'net_quantity',
            'coin_type',
            'year',
            'created'
        ]

class MonthlyBalanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MonthlyBalance
        fields = [
            'gross_quantity',
            'net_quantity',
            'coin_type',
            'year',
            'month',
            'created'
        ]
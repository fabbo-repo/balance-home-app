from rest_framework import serializers
from balance.models import AnnualBalance, MonthlyBalance


class AnnualBalanceSerializer(serializers.ModelSerializer):
    # Foreign Key fields like coin_type will only show its primary key
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
    # Foreign Key fields like coin_type will only show its primary key
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
from rest_framework import serializers
from balance.models import AnnualBalance, MonthlyBalance


class AnnualBalanceSerializer(serializers.ModelSerializer):
    # Foreign Key fields like currency_type will only show its primary key
    class Meta:
        model = AnnualBalance
        fields = [
            "gross_quantity",
            "expected_quantity",
            "currency_type",
            "year",
            "created"
        ]

class MonthlyBalanceSerializer(serializers.ModelSerializer):
    # Foreign Key fields like currency_type will only show its primary key
    class Meta:
        model = MonthlyBalance
        fields = [
            "gross_quantity",
            "expected_quantity",
            "currency_type",
            "year",
            "month",
            "created"
        ]
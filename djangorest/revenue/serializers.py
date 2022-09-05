from rest_framework import serializers
from revenue.models import Revenue


class RevenueSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)
    class Meta:
        model = Revenue
        fields = [
            'id',
            'name',
            'description',
            'quantity',
            'date',
            'coin_type',
            'rev_type'
        ]
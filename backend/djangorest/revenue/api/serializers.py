from rest_framework import serializers
from revenue.models import Revenue, RevenueType


class RevenueTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = RevenueType
        fields = [
            'name',
            'image'
        ]

class RevenuePostPutDelSerializer(serializers.ModelSerializer):
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
        read_only_fields = [
            'id'
        ]

class RevenueListDetailSerializer(RevenuePostPutDelSerializer):
    rev_type = RevenueTypeSerializer(many=False)
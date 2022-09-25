from rest_framework import serializers
from expense.models import Expense, ExpenseType


class ExpenseTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseType
        fields = [
            'name',
            'image'
        ]
    
class ExpensePostPutDelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = [
            'id',
            'name',
            'description',
            'quantity',
            'date',
            'coin_type',
            'exp_type'
        ]
        read_only_fields = [
            'id'
        ]

class ExpenseListDetailSerializer(ExpensePostPutDelSerializer):
    exp_type = ExpenseTypeSerializer(many=False)
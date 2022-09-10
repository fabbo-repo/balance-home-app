from rest_framework import serializers
from expense.models import Expense


class ExpenseSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)
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
from rest_framework import serializers
from expense.models import Expense, ExpenseType


class ExpenseTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpenseType
        fields = [
            "name",
            "image"
        ]
    
class ExpensePostPutDelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = [
            "id",
            "name",
            "description",
            "real_quantity",
            "converted_quantity",
            "date",
            "currency_type",
            "exp_type"
        ]
        read_only_fields = [
            "id",
            "converted_quantity"
        ]

class ExpenseListDetailSerializer(ExpensePostPutDelSerializer):
    exp_type = ExpenseTypeSerializer(many=False)
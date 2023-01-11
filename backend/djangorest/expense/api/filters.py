from django_filters import rest_framework as filters
from expense.models import Expense


class ExpenseFilterSet(filters.FilterSet):
    converted_quantity_min = filters.NumberFilter(
        field_name = "converted_quantity",
        lookup_expr = "gte",
        label = "Min converted quantity"
    )
    converted_quantity_max = filters.NumberFilter(
        field_name = "converted_quantity",
        lookup_expr = "lte",
        label = "Max converted quantity"
    )
    date_from = filters.DateFilter(
        field_name = "date",
        lookup_expr = "gte",
        label = "Date From"
    )
    date_to = filters.DateFilter(
        field_name = "date",
        lookup_expr = "lte",
        label = "Date To"
    )
    class Meta:
        model = Expense
        fields = ["exp_type", "date", "coin_type"]
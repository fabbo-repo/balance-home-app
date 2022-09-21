from django_filters import rest_framework as filters
from expense.models import Expense


class ExpenseFilterSet(filters.FilterSet):
    quantity_min = filters.BooleanFilter(
        field_name = "quantity",
        lookup_expr = "gte",
        label = "Min quantity"
    )
    quantity_max = filters.BooleanFilter(
        field_name = "quantity",
        lookup_expr = "lte",
        label = "Max quantity"
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
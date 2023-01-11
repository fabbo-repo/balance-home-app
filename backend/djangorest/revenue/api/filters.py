from django_filters import rest_framework as filters
from revenue.models import Revenue


class RevenueFilterSet(filters.FilterSet):
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
        field_name = "date", lookup_expr = "gte",
        label = "Date From"
    )
    date_to = filters.DateFilter(
        field_name = "date", 
        lookup_expr = "lte",
        label = "Date To"
    )
    class Meta:
        model = Revenue
        fields = ["rev_type", "date", "coin_type"]
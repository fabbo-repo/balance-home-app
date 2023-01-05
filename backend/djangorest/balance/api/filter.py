from django_filters import rest_framework as filters
from balance.models import AnnualBalance, MonthlyBalance


class AnnualBalanceFilterSet(filters.FilterSet):
    gross_quantity_min = filters.NumberFilter(
        field_name = "gross_quantity",
        lookup_expr = "gte",
        label = "Min gross quantity"
    )
    gross_quantity_max = filters.NumberFilter(
        field_name = "gross_quantity",
        lookup_expr = "lte",
        label = "Max gross quantity"
    )
    expected_quantity_min = filters.NumberFilter(
        field_name = "expected_quantity",
        lookup_expr = "gte",
        label = "Min expected quantity"
    )
    expected_quantity_max = filters.NumberFilter(
        field_name = "expected_quantity",
        lookup_expr = "lte",
        label = "Max expected quantity"
    )
    
    class Meta:
        model = AnnualBalance
        fields = ["coin_type", "year"]


class MonthlyBalanceFilterSet(AnnualBalanceFilterSet):
    class Meta:
        model = MonthlyBalance
        fields = ["coin_type", "year", "month"]

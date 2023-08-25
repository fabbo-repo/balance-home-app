from django.urls import path
from balance.api.views import AnnualBalanceView, MonthlyBalanceView

annual_balance_list = AnnualBalanceView.as_view({
    "get": "list",
})
annual_balance_detail = AnnualBalanceView.as_view({
    "get": "retrieve",
})

monthly_balance_list = MonthlyBalanceView.as_view({
    "get": "list",
})
monthly_balance_detail = MonthlyBalanceView.as_view({
    "get": "retrieve",
})

urlpatterns = [
    path("annual_balance", annual_balance_list, name="annual-balance-list"),
    path("annual_balance/<int:pk>", annual_balance_detail,
         name="annual-balance-detail"),
    path("monthly_balance", monthly_balance_list, name="monthly-balance-list"),
    path("monthly_balance/<int:pk>", monthly_balance_detail,
         name="monthly-balance-detail"),
]

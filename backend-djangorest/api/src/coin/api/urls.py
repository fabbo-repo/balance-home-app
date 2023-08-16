from django.urls import path
from coin.api.views import (
    CoinTypeRetrieveView, 
    CoinTypeListView,
    CoinExchangeRetrieveView,
    CoinExchangeListView
)


urlpatterns = [
    path("coin/type/<str:pk>", CoinTypeRetrieveView.as_view(), name="currency_type_get"),
    path("coin/type", CoinTypeListView.as_view(), name="currency_type_list"),
    path("coin/exchange/days=<int:days>", CoinExchangeListView.as_view(), name="currency_exchange_list"),
    path("coin/exchange/<str:code>", CoinExchangeRetrieveView.as_view(), name="currency_exchange_code")
]
from django.urls import path
from coin.api.views import (
    CoinTypeRetrieveView, 
    CoinTypeListView,
    CoinExchangeRetrieveView,
    CoinExchangeListView
)


urlpatterns = [
    path("coin/type/<str:pk>", CoinTypeRetrieveView.as_view(), name='coin_type_get'),
    path("coin/type", CoinTypeListView.as_view(), name='coin_type_list'),
    path("coin/exchange/days=<int:days>", CoinExchangeListView.as_view(), name='coin_exchange_list'),
    path("coin/exchange/<str:code>", CoinExchangeRetrieveView.as_view(), name='coin_exchange_code')
]
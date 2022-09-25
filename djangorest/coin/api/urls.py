from django.urls import path
from coin.api.views import (
    CoinTypeRetrieveView, 
    CoinTypeListView
)


urlpatterns = [
    path("coin/type/<str:pk>", CoinTypeRetrieveView.as_view(), name='coin_type_get'),
    path("coin/type", CoinTypeListView.as_view(), name='coin_type_list')
]
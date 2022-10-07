from django.urls import path, include
from revenue.api.views import (
    RevenueView, 
    RevenueTypeRetrieveView, 
    RevenueTypeListView
)
from rest_framework import routers

# trailing_slash=False erase the '/' character at the end of the url
router = routers.DefaultRouter(trailing_slash=False)
router.register('revenue', RevenueView)


urlpatterns = [
    path("revenue/type/<str:pk>", RevenueTypeRetrieveView.as_view(), name='rev_type_get'),
    path("revenue/type", RevenueTypeListView.as_view(), name='rev_type_list'),
    path("", include(router.urls)),
]
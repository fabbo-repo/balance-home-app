from django.urls import path, include
from revenue.views import RevenueView
from rest_framework import routers

# trailing_slash=False erase the '/' character at the end of the url
router = routers.DefaultRouter(trailing_slash=False)
router.register('revenue', RevenueView)


urlpatterns = [
    path("", include(router.urls)),
]
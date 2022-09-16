from django.urls import path, include
from expense.api.views import ExpenseView
from rest_framework import routers

# trailing_slash=False erase the '/' character at the end of the url
router = routers.DefaultRouter(trailing_slash=False)
router.register('expense', ExpenseView)


urlpatterns = [
    path("", include(router.urls)),
]
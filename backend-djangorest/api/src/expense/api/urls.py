from django.urls import path, include
from expense.api.views import (
    ExpenseView,
    ExpenseTypeRetrieveView,
    ExpenseTypeListView,
    EspenseYearsRetrieveView,
)
from rest_framework import routers

# trailing_slash=False erase the /" character at the end of the url
router = routers.DefaultRouter(trailing_slash=False)
router.register("expense", ExpenseView)


urlpatterns = [
    path(
        "expense/type/<str:pk>",
        ExpenseTypeRetrieveView.as_view(),
        name="expense-type-get",
    ),
    path("expense/type", ExpenseTypeListView.as_view(), name="expense-type-list"),
    path("expense/years", EspenseYearsRetrieveView.as_view(), name="expense-years"),
    path("", include(router.urls)),
]

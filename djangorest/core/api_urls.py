from django.contrib import admin
from django.urls import path, include
from core.swagger import urls as swagger_urls
from custom_auth.api import urls as auth_urls
from revenue.api import urls as revenue_urls
from expense.api import urls as expense_urls
from django.conf.urls.static import static

urlpatterns = [
    # Auth app urls:
    path("", include(auth_urls)),
    # Revenue app urls:
    path("", include(revenue_urls)),
    # Expense app urls:
    path("", include(expense_urls)),
]
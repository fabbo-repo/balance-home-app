from django.urls import path, include
from custom_auth.api import urls as auth_urls
from revenue.api import urls as revenue_urls
from expense.api import urls as expense_urls
from balance.api import urls as balance_urls
from coin.api import urls as coin_urls
from frontend_version.api import urls as frontend_version_urls

urlpatterns = [
    # Auth app urls:
    path("", include(auth_urls)),
    # Revenue app urls:
    path("", include(revenue_urls)),
    # Expense app urls:
    path("", include(expense_urls)),
    # Balance app urls:
    path("", include(balance_urls)),
    # Coin app urls:
    path("", include(coin_urls)),
    # Frontend version app urls:
    path("", include(frontend_version_urls)),
]
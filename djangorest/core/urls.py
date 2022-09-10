"""core URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from core.swagger import urls as swagger_urls
from custom_auth import urls as auth_urls
from revenue import urls as revenue_urls
from expense import urls as expense_urls
from django.conf.urls.static import static

urlpatterns = [
    path('api/v1/admin/', admin.site.urls),
    # Auth app urls:
    path("api/v1/", include(auth_urls)),
    # Revenue app urls:
    path("api/v1/", include(revenue_urls)),
    # Expense app urls:
    path("api/v1/", include(expense_urls)),
]

# Swagger will only be available in DEBUG mode
if settings.DEBUG:
    urlpatterns += [
        path("api/v1/swagger/", include(swagger_urls)),
    ]
    urlpatterns += static(
        settings.MEDIA_URL, 
        document_root=settings.MEDIA_ROOT
    )
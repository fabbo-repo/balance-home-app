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
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from core.swagger import urls as swagger_urls
from django.conf import settings

urlpatterns = [
    path('api/v1/admin/', admin.site.urls),
    path("api/v1/jwt/", TokenObtainPairView.as_view(), name="jwt_obtain_pair"),
    path("api/v1/jwt/refresh/", TokenRefreshView.as_view(), name="jwt_refresh"),
]

# Swagger will only be available in DEBUG mode
if settings.DEBUG:
    urlpatterns += [
        path("api/v1/swagger/", include(swagger_urls)),
    ]

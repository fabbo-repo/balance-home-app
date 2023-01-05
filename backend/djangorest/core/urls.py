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
from core import api_urls
from django.conf.urls.static import static

urlpatterns = []

# Swagger and documentation will only be available in DEBUG mode
if settings.DEBUG:
    urlpatterns += [
        # Documentation:
        path('general/admin/doc/', include('django.contrib.admindocs.urls')),
        # Swagger:
        path("api/v1/swagger/", include(swagger_urls)),
    ]
    urlpatterns += static(
        settings.MEDIA_URL, 
        document_root=settings.MEDIA_ROOT
    )

urlpatterns += [
    path('general/admin/', admin.site.urls),
    path("api/v1/", include(api_urls)),
]
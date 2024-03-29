from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from core.swagger import urls as swagger_urls
from core import api_urls
from django.conf.urls.static import static
from core.views import favicon_view

handler404 = 'core.views.not_found_view'
handler500 = 'core.views.error_view'
handler403 = 'core.views.permission_denied_view'
handler400 = 'core.views.bad_request_view'

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

if not settings.DISABLE_ADMIN_PANEL:
    urlpatterns += [
        path('general/admin/', admin.site.urls),
    ]

urlpatterns += [
    path("api/v1/", include(api_urls)),
    path("favicon.ico", favicon_view),
]

from django.urls import path
from frontend_version.api.views import FrontendVersionView

urlpatterns = [
    path("frontend/version", FrontendVersionView.as_view(), name='frontend_version_get')
]
from django.urls import path, re_path
from drf_yasg import openapi
from drf_yasg.views import get_schema_view
from django.conf import settings
from rest_framework.permissions import AllowAny

# Schema view for the swagger:
schema_view = get_schema_view(
    openapi.Info(
        title="Balance Home App API",
        default_version="v1",
        description="API for Balance Home App",
    ),
    public=True,
    permission_classes=(AllowAny,)
)

urlpatterns = [
    re_path(
        r"^(?P<format>\.json|\.yaml)$",
        schema_view.without_ui(cache_timeout=0),
        name="schema-json",
    ),
    path(
        "",
        schema_view.with_ui("swagger", cache_timeout=0),
        name="schema-swagger-ui",
    ),
]

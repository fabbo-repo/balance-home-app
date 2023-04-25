from django.utils.translation import gettext_lazy as _
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from django.conf import settings


class FrontendVersionView(APIView):
    permission_classes = (AllowAny,)

    @method_decorator(cache_page(60))
    def get(self, request, format=None):
        """
        This view will be cached for 60 seconds
        """
        return Response(
            data={
                'version': settings.APP_FRONTEND_VERSION
            }
        )

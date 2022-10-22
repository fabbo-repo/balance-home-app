from django.utils.translation import gettext_lazy as _
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from frontend_version.api.serializers import FrontendVersionSerializer
from frontend_version.models import FrontendVersion
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny


class FrontendVersionView(APIView):
    serializer_class = FrontendVersionSerializer
    permission_classes = (AllowAny,)

    @method_decorator(cache_page(12 * 60 * 60))
    def get(self, request, format=None):
        """
        This view will be cached for 12 hours
        """
        try:
            return Response(
                data= {
                    'version': FrontendVersion.objects.last().version
                }
            )
        except:
            return Response(
                data= {
                    'version': "0.0.0"
                }
            )
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

    @method_decorator(cache_page(10))
    def get(self, request, format=None):
        """
        This view will be cached for 10 seconds
        """
        try:
            return Response(
                data= {
                    'version': FrontendVersion.objects.first().version
                }
            )
        except:
            return Response(
                data= {
                    'version': "1.0.0"
                }
            )
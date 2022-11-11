from custom_auth.api.serializers.jwt_serializers import (
    CustomTokenObtainPairSerializer, 
    CustomTokenRefreshSerializer
)
from rest_framework.parsers import JSONParser
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView


class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = CustomTokenObtainPairSerializer
    parser_classes = (JSONParser,)

class CustomTokenRefreshView(TokenRefreshView):
    """
    Refresh token generator view.
    """
    serializer_class = CustomTokenRefreshSerializer

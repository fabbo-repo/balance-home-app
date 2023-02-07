from custom_auth.api.serializers.jwt_serializers import (
    CustomTokenObtainPairSerializer,
    CustomTokenRefreshSerializer
)
from rest_framework.parsers import JSONParser
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework.throttling import ScopedRateThrottle


class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = CustomTokenObtainPairSerializer
    parser_classes = (JSONParser,)
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "jwt_obtain_pair"


class CustomTokenRefreshView(TokenRefreshView):
    """
    Refresh token generator view.
    """
    serializer_class = CustomTokenRefreshSerializer
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "jwt_refresh"

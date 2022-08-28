from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from custom_auth.views import RegisterView

urlpatterns = [
    path("jwt/", TokenObtainPairView.as_view(), name="jwt_obtain_pair"),
    path("jwt/refresh/", TokenRefreshView.as_view(), name="jwt_refresh"),
    path("register/", RegisterView.as_view(), name="register"),
]
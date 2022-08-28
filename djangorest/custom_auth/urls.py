from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from custom_auth.views import CustomTokenObtainPairView, RegisterView

urlpatterns = [
    path("jwt", CustomTokenObtainPairView.as_view(), name="jwt_obtain_pair"),
    path("jwt/refresh", TokenRefreshView.as_view(), name="jwt_refresh"),
    path("register", RegisterView.as_view(), name="register"),
    path("email_code/send", RegisterView.as_view(), name="email_code_send"),
    path("email_code/resend", RegisterView.as_view(), name="email_code_resend"),
]
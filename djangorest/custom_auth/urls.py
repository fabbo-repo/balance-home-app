from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from custom_auth.views import (
    ChangePasswordView,
    CodeVerificationView, 
    CodeView, 
    CustomTokenObtainPairView, 
    UserCreationView, 
    UserRetrieveUpdateDestroyView
)

urlpatterns = [
    path("jwt", CustomTokenObtainPairView.as_view(), name="jwt_obtain_pair"),
    path("jwt/refresh", TokenRefreshView.as_view(), name="jwt_refresh"),
    path("user", UserCreationView.as_view(), name="user_post"),
    path("user/<uuid:pk>", UserRetrieveUpdateDestroyView.as_view(), name='user_put_get_del'),
    path('user/password/change', ChangePasswordView.as_view(), name='change_password'),
    path('user/password/reset', ChangePasswordView.as_view(), name='reset_password'),
    path("pass_reset/send", CodeView.as_view(), name="pass_reset_send"),
    path("email_code/send", CodeView.as_view(), name="email_code_send"),
    path("email_code/verify", CodeVerificationView.as_view(), name="email_code_verify"),
]
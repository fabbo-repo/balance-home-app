from django.urls import path
from app_auth.api.views.password_views import (
    ResetPasswordView,
)
from app_auth.api.views.user_views import (
    UserCreationView,
    UserRetrieveUpdateDestroyView,
    SendVerifyEmailView,
)

urlpatterns = [
    path("user", UserCreationView.as_view(), name="user-post"),
    path("user/profile", UserRetrieveUpdateDestroyView.as_view(),
         name="user-put-get-del"),
    path("user/send-verify-email", SendVerifyEmailView.as_view(),
         name="send-verify-email"),
    path("user/password-reset", ResetPasswordView.as_view(),
         name="reset-password"),
]

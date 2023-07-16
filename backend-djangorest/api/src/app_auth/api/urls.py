from django.urls import path
from app_auth.api.views.password_views import (
    ChangePasswordView,
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
    path("user/password/change", ChangePasswordView.as_view(),
         name="change-password"),
    path("user/password/reset", ResetPasswordView.as_view(),
         name="reset-password"),
]

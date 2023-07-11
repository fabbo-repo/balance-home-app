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
    path("user", UserCreationView.as_view(), name="user_post"),
    path("user/profile", UserRetrieveUpdateDestroyView.as_view(),
         name='user_put_get_del'),
    path("user/send-verify-email", SendVerifyEmailView.as_view(), name="send_verify_email"),
    path('user/password/change', ChangePasswordView.as_view(),
         name='change_password'),
    path('user/password/reset', ResetPasswordView.as_view(),
         name='reset_password'),
]

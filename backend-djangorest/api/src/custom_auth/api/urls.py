from django.urls import path
from custom_auth.api.views.code_views import (
    ChangePasswordView,
    CodeVerificationView,
    CodeView,
    ResetPasswordStartView,
    ResetPasswordVerifyView,
)
from custom_auth.api.views.user_views import (
    UserCreationView,
    UserRetrieveUpdateDestroyView
)

urlpatterns = [
    path("user", UserCreationView.as_view(), name="user_post"),
    path("email_code/send", CodeView.as_view(), name="email_code_send"),
    path("email_code/verify", CodeVerificationView.as_view(),
         name="email_code_verify"),
    path("user/profile", UserRetrieveUpdateDestroyView.as_view(),
         name='user_put_get_del'),
    path('user/password/change', ChangePasswordView.as_view(),
         name='change_password'),
    path('user/password/reset/start', ResetPasswordStartView.as_view(),
         name='reset_password_start'),
    path('user/password/reset/verify', ResetPasswordVerifyView.as_view(),
         name='reset_password_verify'),
]

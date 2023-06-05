from django.urls import path
from custom_auth.api.views.password_views import (
    ChangePasswordView,
    ResetPasswordView,
)
from custom_auth.api.views.user_views import (
    UserCreationView,
    UserRetrieveUpdateDestroyView
)

urlpatterns = [
    path("user", UserCreationView.as_view(), name="user_post"),
    path("user/profile", UserRetrieveUpdateDestroyView.as_view(),
         name='user_put_get_del'),
    path('user/password/change', ChangePasswordView.as_view(),
         name='change_password'),
    path('user/password/reset', ResetPasswordView.as_view(),
         name='reset_password'),
]

from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from custom_auth.views import (
    CodeVerificationView, 
    CodeView, 
    CustomTokenObtainPairView, 
    UserCreationView, 
    UserUpdateView,
    UserRetrieveDestroyView
)

urlpatterns = [
    path("jwt", CustomTokenObtainPairView.as_view(), name="jwt_obtain_pair"),
    path("jwt/refresh", TokenRefreshView.as_view(), name="jwt_refresh"),
    path("user", UserCreationView.as_view(), name="user_post"),
    path("user/profile/<uuid:pk>", UserUpdateView.as_view(), name='user_put'),
    path('user/<uuid:pk>', UserRetrieveDestroyView.as_view(), name='user_get_del'),
    #path('user/<uuid:pk>', user_get_del_view, name='user_del'),
    path("email_code/send", CodeView.as_view(), name="email_code_send"),
    path("email_code/verify", CodeVerificationView.as_view(), name="email_code_verify"),
]
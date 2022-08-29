from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from custom_auth.serializers.login_serializers import CodeSerializer, CodeVerificationSerializer, CustomTokenObtainPairSerializer
from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.views import TokenObtainPairView
from custom_auth.serializers.user_serializers import (
    UserCreationSerializer,
    UserUpdateSerializer,
    UserRetrieveDestroySerializer
)

class UserCreationView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = UserCreationSerializer

class UserUpdateView(generics.UpdateAPIView):
    queryset = User.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    serializer_class = UserUpdateSerializer

class UserRetrieveDestroyView(generics.RetrieveDestroyAPIView):
    queryset = User.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    serializer_class = UserRetrieveDestroySerializer

class CodeView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeSerializer

class CodeVerificationView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeVerificationSerializer

class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = CustomTokenObtainPairSerializer


"""
class UserViewSet(viewsets.ModelViewSet) :
    queryset = User.objects.all()

    def get_serializer_class(self):
        if self.action in ('retrieve', 'update', 'destroy'):
            return UserRetrieveUpdateSerializer
        return UserCreationSerializer
    
    def get_permissions(self):
        # UserPermission for user changes
        if self.action in ('retrieve', 'update', 'destroy'):
            self.permission_classes = (IsCurrentUser,)
        # Allow any only for user creation
        self.permission_classes = (AllowAny,)
        
        return super().get_permissions()
"""

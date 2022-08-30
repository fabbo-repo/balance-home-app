from core.permissions import IsCurrentVerifiedUser
from custom_auth.models import User
from custom_auth.serializers.jwt_code_serializers import CodeSerializer, CodeVerificationSerializer, CustomTokenObtainPairSerializer
from rest_framework import generics, status
from rest_framework.parsers import FormParser, MultiPartParser, JSONParser
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from custom_auth.serializers.user_serializers import (
    ChangePasswordSerializer,
    UserCreationSerializer,
    UserUpdateSerializer
)

class UserCreationView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = UserCreationSerializer
    parser_classes = (FormParser, JSONParser,)

class UserRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = User.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    serializer_class = UserUpdateSerializer
    parser_classes = (MultiPartParser, FormParser, JSONParser)

class CodeView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeSerializer

class CodeVerificationView(generics.CreateAPIView):
    permission_classes = (AllowAny,)
    serializer_class = CodeVerificationSerializer

class CustomTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = CustomTokenObtainPairSerializer

class ChangePasswordView(generics.UpdateAPIView):
    """
    An endpoint for changing password.
    """
    serializer_class = ChangePasswordSerializer
    model = User
    permission_classes = (IsCurrentVerifiedUser,)

    def get_object(self, queryset=None):
        obj = self.request.user
        return obj

    def update(self, request, *args, **kwargs):
        self.object = self.get_object()
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            # Check old password
            if not self.object.check_password(serializer.data.get("old_password")):
                return Response(
                    {"old_password": ["Wrong password."]}, 
                    status=status.HTTP_400_BAD_REQUEST)
            self.object.set_password(serializer.data.get("new_password"))
            self.object.save()
            response = {
                'status': 'success',
                'code': status.HTTP_200_OK,
                'message': 'Password updated successfully',
                'data': []
            }
            return Response(response)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
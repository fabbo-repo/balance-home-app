from rest_framework import serializers
from custom_auth.models import User
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer


class RegisterSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    email = serializers.EmailField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password]
    )
    password2 = serializers.CharField(
        write_only=True,
        required=True
    )
    #annual_balance = serializers.FloatField(
    #    validators=[MinValueValidator]
    #)
    #monthly_balance = serializers.FloatField(
    #    validators=[MinValueValidator]
    #)
    #join_date = serializers.DateTimeField(
    #    read_only=True
    #)

    class Meta:
        model = User
        fields = (
            'username', 'email',
            'password', 'password2',
        )

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        if attrs['username'] == attrs['password'] or attrs['email'] == attrs['password']:
            raise serializers.ValidationError({"password": "Password field can not match another attribute."})
        return attrs

    def create(self, validated_data):
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
        )
        user.set_password(validated_data['password'])
        user.save()
        return user


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):

    @classmethod
    def get_token(cls, user):
        if not user.verified:
            raise serializers.ValidationError({"verified": "Email is not verified"})
        token = super(CustomTokenObtainPairSerializer, cls).get_token(user)

        # Custom keys added in PAYLOAD
        token['username'] = user.username
        token['email'] = user.email
        return token
from rest_framework import serializers
from custom_auth.models import InvitationCode, User
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.db import transaction


"""
Race condition at usage left update in an InvitationCode
"""
@transaction.atomic()
def decrease_inv_code_usage(code):
    sid = transaction.savepoint()
    inv_code = code #InvitationCode.objects.select_for_update().get(code=code)
    inv_code.usage_left -= 1
    if inv_code.usage_left <= 0: inv_code.is_active = False
    inv_code.save()
    transaction.savepoint_commit(sid)

class RegisterSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    email = serializers.EmailField(
        required=True,
        validators=[UniqueValidator(queryset=User.objects.all())]
    )
    inv_code = serializers.SlugRelatedField(
        required=True,
        slug_field="code", many=False,
        queryset=InvitationCode.objects.all()
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
            'username', 'email', 'inv_code',
            'password', 'password2',
        )

    def validate_inv_code(self, value):
        inv_code = None
        try:
            inv_code = InvitationCode.objects.get(code=value.code)
        except IndexError:
            raise serializers.ValidationError("None InvitationCode provided")
        except:
            raise serializers.ValidationError("InvitationCode not found")
        if not inv_code.is_active:
            raise serializers.ValidationError("Invalid InvitationCode")
        return value

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        if attrs['username'] == attrs['password'] or attrs['email'] == attrs['password']:
            raise serializers.ValidationError({"password": "Password field can not match another attribute."})
        return attrs

    def create(self, validated_data):
        inv_code = validated_data['inv_code']
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data['email'],
            inv_code=inv_code
        )
        user.set_password(validated_data['password'])
        decrease_inv_code_usage(inv_code)
        user.save()
        return user


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):

    @classmethod
    def get_token(cls, user):
        if not user.inv_code:
            raise serializers.ValidationError({"inv_code": "No InvitationCode stored"})
        if not user.verified:
            raise serializers.ValidationError({"verified": "Email is not verified"})
        token = super(CustomTokenObtainPairSerializer, cls).get_token(user)

        # Custom keys added in PAYLOAD
        token['username'] = user.username
        token['email'] = user.email
        return token
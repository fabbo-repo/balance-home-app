from rest_framework import serializers
from custom_auth.models import InvitationCode, User
from rest_framework.validators import UniqueValidator
from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils.timezone import now
from django.conf import settings


"""
Race condition at usage left update in an InvitationCode
"""
@transaction.atomic()
def decrease_inv_code_usage(code):
    sid = transaction.savepoint()
    inv_code = code
    inv_code.usage_left -= 1
    if inv_code.usage_left <= 0: inv_code.is_active = False
    inv_code.save()
    transaction.savepoint_commit(sid)

"""
Checks if an invitation code is created and valid
"""
def check_inv_code(code):
    inv_code = None
    try: inv_code = InvitationCode.objects.get(code=code)
    except: raise serializers.ValidationError("InvitationCode not found")
    if not inv_code.is_active:
        raise serializers.ValidationError("Invalid InvitationCode")

"""
Checks if 2 passwords are different, also that username and email 
are different to the passwords
"""
def check_username_pass12(username, email, password1, password2):
    if password1 != password2:
        raise serializers.ValidationError(
            {"password": "Password fields didn't match."})
    if username == password1 or email == password1:
        raise serializers.ValidationError(
            {"password": "Password field can not match another attribute."})


"""
Serializer for User creation (register)
"""
class UserCreationSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        required=True, max_length=15,
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

    class Meta:
        model = User
        fields = (
            'username', 'email', 'inv_code',
            'password', 'password2',
        )

    def validate_inv_code(self, value):
        check_inv_code(value.code)
        return value

    def validate(self, attrs):
        check_username_pass12(attrs['username'], attrs['email'], 
            attrs['password'], attrs['password2'])
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


"""
Serializer to get, update or delete user data
"""
class UserUpdateSerializer(serializers.ModelSerializer):
    username = serializers.CharField(
        max_length=15,
        validators=[UniqueValidator(queryset=User.objects.all())],
        required=False
    )
    email = serializers.EmailField(
        validators=[UniqueValidator(queryset=User.objects.all())],
        required=False
    )
    annual_balance = serializers.IntegerField(required=False)
    monthly_balance = serializers.IntegerField(required=False)
    image = serializers.ImageField(required=False)
    last_login = serializers.ReadOnlyField()

    class Meta:
        model = User
        fields = (
            'username', 'email',
            'annual_balance', 'monthly_balance',
            'image', 'last_login'
        )

    def update(self, instance, validated_data):
        if 'email' in validated_data:
            validated_data['verified'] = False
        return super(UserUpdateSerializer, self).update(instance, validated_data)


"""
Serializer for password change (needs old password)
"""
class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )

"""
Serializer for password reset (code verification)
"""
class ResetPasswordSerializer(serializers.Serializer):
    code = serializers.CharField(
        required=True, 
        min_length=6, max_length=6
    )
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password]
    )

    def validate_code(self, code):
        user = self.user
        if not user.date_pass_reset:
            raise serializers.ValidationError("None code sent")
        if user.date_pass_reset:
            duration_s = (now() - user.date_pass_reset).total_seconds()
            if duration_s > settings.EMAIL_CODE_VALID :
                raise serializers.ValidationError(
                    "Code is no longer valid")
        if user.pass_reset != code :
            raise serializers.ValidationError(
                "Invalid code")
        return code

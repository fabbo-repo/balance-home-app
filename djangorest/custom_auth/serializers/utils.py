from rest_framework import serializers
from custom_auth.models import User

"""
Checks an user exists with email arg and is verified
"""
def check_user_with_email(email):
    user = None
    try: user = User.objects.get(email=email)
    except: raise serializers.ValidationError(
            {"email": "User not found"})
    if user.verified:
        raise serializers.ValidationError(
            {"email": "User already verified"})


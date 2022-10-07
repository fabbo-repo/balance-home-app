from rest_framework import serializers
from custom_auth.models import User
from django.utils.translation import gettext_lazy as _

def check_user_with_email(email):
    """
    Checks an user exists with email arg and is verified
    """
    user = None
    try: user = User.objects.get(email=email)
    except: raise serializers.ValidationError(
            {"email": _("User not found")})
    if user.verified:
        raise serializers.ValidationError(
            {"email": _("User already verified")})


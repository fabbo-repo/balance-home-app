from custom_auth.models import User
from django.utils.translation import gettext_lazy as _
from custom_auth.models import InvitationCode
from rest_framework.serializers import ValidationError


def check_user_with_email(email):
    """
    Checks an user exists with email arg and is verified
    """
    user = None
    try:
        user = User.objects.get(email=email)
    except:
        raise ValidationError(
            {"email": _("User not found")})
    if user.verified:
        raise ValidationError(
            {"email": _("User already verified")})


def check_username_pass12(username, email, password1, password2):
    """
    Checks if 2 passwords are different, also that username and email 
    are different to the passwords
    """
    if password1 != password2:
        raise ValidationError(
            {"password": _("Password fields do not match")})
    if username == password1 or email == password1:
        raise ValidationError(
            {"password": _("Password cannot match other profile data")})

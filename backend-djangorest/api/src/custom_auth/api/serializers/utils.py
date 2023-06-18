from custom_auth.models import User
from django.utils.translation import gettext_lazy as _
from rest_framework.serializers import ValidationError


def check_username_pass(username, email, password):
    """
    Checks if username and email are different to the passwords
    """
    if username == password or email == password:
        raise ValidationError(
            {"password": _("Password cannot match other profile data")})

from typing import OrderedDict
from rest_framework import permissions
from custom_auth.models import User


class IsCurrentVerifiedUser(permissions.IsAuthenticated):
    message = 'Unauthorized operation'

    def has_object_permission(self, request, view, obj):
        if type(obj) == User:
            return bool(request.user) and obj == request.user and obj.verified
        return bool(request.user) and obj.owner == request.user

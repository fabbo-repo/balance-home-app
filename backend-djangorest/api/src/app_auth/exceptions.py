"""
Provides app exceptions classes.
"""
from core.exceptions import AppBadRequestException
from django.utils.translation import gettext_lazy as _


SAME_USERNAME_EMAIL_ERROR = 5
USER_EMAIL_CONFLICT_ERROR = 6
CANNOT_CREATE_USER_ERROR = 7
RESET_PASSW_RETRIES_ERROR = 10
NEW_OLD_PASSW_ERROR = 11
NEW_PASSW_USER_DATA_ERROR = 12


class SameUsernameEmailException(AppBadRequestException):
    """
    Exception used when an username and email can not be the same.
    """
    def __init__(self):
        detail = _("Username and email can not be the same")
        super().__init__(detail, SAME_USERNAME_EMAIL_ERROR)


class UserEmailConflictException(AppBadRequestException):
    """
    Exception used when an email is already used.
    """
    def __init__(self):
        detail = _("Email already used")
        super().__init__(detail, USER_EMAIL_CONFLICT_ERROR)


class CannotCreateUserException(AppBadRequestException):
    """
    Exception used when an user cannot be created.
    """
    def __init__(self):
        detail = _("Cannot create user")
        super().__init__(detail, CANNOT_CREATE_USER_ERROR)


class ResetPasswordRetriesException(AppBadRequestException):
    """
    Exception used when only three codes can be sent per day.
    """
    def __init__(self):
        detail = _("Only three codes can be sent per day")
        super().__init__(detail, RESET_PASSW_RETRIES_ERROR)


class NewOldPasswordException(AppBadRequestException):
    """
    Exception used when only three codes can be sent per day.
    """
    def __init__(self):
        detail = _("New password must be different from old password")
        super().__init__(detail, NEW_OLD_PASSW_ERROR)


class NewPasswordUserDataException(AppBadRequestException):
    """
    Exception used when new password cannot match other profile data.
    """
    def __init__(self):
        detail = _("New password cannot match other profile data")
        super().__init__(detail, NEW_PASSW_USER_DATA_ERROR)

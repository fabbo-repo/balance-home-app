"""
Provides app exceptions classes.
"""
from core.exceptions import AppBadRequestException
from django.utils.translation import gettext_lazy as _


USER_NOT_FOUND_ERROR = 1
UNVERIFIED_EMAIL_ERROR = 2
CANNOT_SEND_VERIFY_EMAIL_ERROR = 3
CANNOT_SEND_RESET_PASSWORD_EMAIL_ERROR = 4
USER_EMAIL_CONFLICT_ERROR = 6
CANNOT_CREATE_USER_ERROR = 7
CANNOT_UPDATE_USER_ERROR = 8
CANNOT_DELETE_USER_ERROR = 9
RESET_PASSW_RETRIES_ERROR = 10
NEW_OLD_PASSW_ERROR = 11
NEW_PASSW_USER_DATA_ERROR = 12
CURRENCY_TYPE_CHANGED_ERROR = 13
WRONG_OLD_PASSW_ERROR = 14
CANNOT_CHANGE_PASSWORD_ERROR = 15


class UserNotFoundException(AppBadRequestException):
    """
    Exception used when an user is not found.
    """

    def __init__(self):
        detail = _("User not found")
        super().__init__(detail, USER_NOT_FOUND_ERROR)


class UnverifiedEmailException(AppBadRequestException):
    """
    Exception used when email has not been verified.
    """

    def __init__(self):
        detail = _("Unverified email")
        super().__init__(detail, UNVERIFIED_EMAIL_ERROR)


class CannotSendVerifyEmailException(AppBadRequestException):
    """
    Exception used when verification mail cannot be sent.
    """

    def __init__(self):
        detail = _("Cannot send verification mail")
        super().__init__(detail, CANNOT_SEND_VERIFY_EMAIL_ERROR)


class CannotSendResetPasswordEmailException(AppBadRequestException):
    """
    Exception used when reset password mail cannot be sent.
    """

    def __init__(self):
        detail = _("Cannot send reset password mail")
        super().__init__(detail, CANNOT_SEND_RESET_PASSWORD_EMAIL_ERROR)


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


class CannotUpdateUserException(AppBadRequestException):
    """
    Exception used when an user cannot be updated.
    """

    def __init__(self):
        detail = _("Cannot update user")
        super().__init__(detail, CANNOT_UPDATE_USER_ERROR)


class CannotDeleteUserException(AppBadRequestException):
    """
    Exception used when an user cannot be deleted.
    """

    def __init__(self):
        detail = _("Cannot delete user")
        super().__init__(detail, CANNOT_DELETE_USER_ERROR)


class ResetPasswordRetriesException(AppBadRequestException):
    """
    Exception used when password can only be reset 3 times a day.
    """

    def __init__(self):
        detail = _("Password can only be reset 3 times a day")
        super().__init__(detail, RESET_PASSW_RETRIES_ERROR)


class NewOldPasswordException(AppBadRequestException):
    """
    Exception used when new password must be different from old password.
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


class CurrencyTypeChangedException(AppBadRequestException):
    """
    Exception used when currency type has already been changed in the las 24 hours
    """

    def __init__(self):
        detail = _("Currency type has already been changed in the las 24 hours")
        super().__init__(detail, CURRENCY_TYPE_CHANGED_ERROR)


class WronOldPasswordException(AppBadRequestException):
    """
    Exception used when old password is invalid
    """

    def __init__(self):
        detail = _("Invalid old password")
        super().__init__(detail, WRONG_OLD_PASSW_ERROR)


class CannotChangePasswordException(AppBadRequestException):
    """
    Exception used when password cannot be changed.
    """

    def __init__(self):
        detail = _("Cannot change password")
        super().__init__(detail, CANNOT_CHANGE_PASSWORD_ERROR)

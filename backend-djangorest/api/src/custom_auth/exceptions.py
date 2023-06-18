from core.exceptions import AppBadRequestException
from django.utils.translation import gettext_lazy as _
from django.conf import settings


NO_INV_CODE_ERROR = 1
SAME_USERNAME_EMAIL_ERROR = 5
USER_EMAIL_CONFLICT_ERROR = 6
CANNOT_CREATE_USER_ERROR = 7
RESET_PASSW_RETRIES_ERROR = 10
NEW_OLD_PASSW_ERROR = 11
NEW_PASSW_USER_DATA_ERROR = 12


class NoInvitationCodeException(AppBadRequestException):
    def __init__(self):
        detail = _("No invitation code stored")
        super().__init__(detail, NO_INV_CODE_ERROR)


class SameUsernameEmailException(AppBadRequestException):
    def __init__(self):
        detail = _("Username and email can not be the same")
        super().__init__(detail, SAME_USERNAME_EMAIL_ERROR)


class UserEmailConflictException(AppBadRequestException):
    def __init__(self):
        detail = _("Email already used")
        super().__init__(detail, USER_EMAIL_CONFLICT_ERROR)


class CannotCreateUserException(AppBadRequestException):
    def __init__(self):
        detail = _("Cannot create user")
        super().__init__(detail, CANNOT_CREATE_USER_ERROR)


class ResetPasswordRetriesException(AppBadRequestException):
    def __init__(self):
        detail = _("Only three codes can be sent per day")
        super().__init__(detail, RESET_PASSW_RETRIES_ERROR)


class NewOldPasswordException(AppBadRequestException):
    def __init__(self):
        detail = _("New password must be different from old password")
        super().__init__(detail, NEW_OLD_PASSW_ERROR)


class NewPasswordUserDataException(AppBadRequestException):
    def __init__(self):
        detail = _("New password cannot match other profile data")
        super().__init__(detail, NEW_PASSW_USER_DATA_ERROR)

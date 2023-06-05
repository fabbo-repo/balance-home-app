from core.exceptions import AppBadRequestException
from django.utils.translation import gettext_lazy as _
from django.conf import settings


NO_INV_CODE_ERROR = 1
UNVERIFIED_EMAIL_ERROR = 2
INVALID_REFRESH_TOKEN_ERROR = 3
INVALID_CREDENTIALS_ERROR = 4
SAME_USERNAME_EMAIL_ERROR = 5
CODE_SENT_ERROR = 6
NO_CODE_SENT_ERROR = 7
NO_LONGER_VALID_CODE_ERROR = 8
INVALID_CODE_ERROR = 9
RESET_PASSW_RETRIES_ERROR = 10
NEW_OLD_PASSW_ERROR = 11
NEW_PASSW_USER_DATA_ERROR = 12


class NoInvitationCodeException(AppBadRequestException):
    def __init__(self):
        detail = _("No invitation code stored")
        super().__init__(detail, NO_INV_CODE_ERROR)


class UnverifiedEmailException(AppBadRequestException):
    def __init__(self):
        detail = _("Unverified email")
        super().__init__(detail, UNVERIFIED_EMAIL_ERROR)


class InvalidRefreshTokenException(AppBadRequestException):
    def __init__(self):
        detail = _('Invalid refresh token')
        super().__init__(detail, INVALID_REFRESH_TOKEN_ERROR)


class InvalidCredentialsException(AppBadRequestException):
    def __init__(self):
        detail = _('No active account found for specified refresh token')
        super().__init__(detail, INVALID_CREDENTIALS_ERROR)


class SameUsernameEmailException(AppBadRequestException):
    def __init__(self):
        detail = _("Username and email can not be the same")
        super().__init__(detail, SAME_USERNAME_EMAIL_ERROR)


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

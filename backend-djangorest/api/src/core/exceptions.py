from rest_framework.views import exception_handler
from rest_framework import status
from rest_framework.exceptions import APIException
from rest_framework.serializers import ValidationError
import logging

logger = logging.getLogger(__name__)


def app_exception_handler(exc: Exception, context):
    response = exception_handler(exc, context)
    if isinstance(exc, AppBadRequestException):
        response.data['error_code'] = exc.error_code
    elif isinstance(exc, ValidationError):
        fields = []
        for field_name in exc.detail:
            for detail in exc.detail[field_name]:
                fields.append({
                    "name": field_name,
                    "detail": detail
                })
        response.data = {
            'fields': fields,
            "detail": exc.default_detail
        }
    return response


class AppBadRequestException(APIException):
    def __init__(self, detail, code):
        self.error_code = code
        super().__init__(detail)
        self.status_code = status.HTTP_400_BAD_REQUEST

    def __str__(self):
        return f'[{self.status_code}] {self.error_code} - {self.detail}'

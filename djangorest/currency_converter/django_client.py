from currency_converter.converter import CurrencyConverterService
from django.conf import settings


def get_converter_from_settings():
    """
    Create an instance of an CurrencyConverterService using the
    COIN_TYPE_CODES from the Django settings.
    """
    return CurrencyConverterService(settings.COIN_TYPE_CODES)
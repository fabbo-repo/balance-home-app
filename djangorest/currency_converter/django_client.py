from coin.models import CoinType
from currency_converter.converter import CurrencyConverterService

def get_converter_from_db():
    """Create an instance of an CurrencyConverterService using the
    coin types stored in db"""
    return CurrencyConverterService([coin.code for coin in CoinType.objects.all()])
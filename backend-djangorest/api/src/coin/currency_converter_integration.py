import json
import logging
from django.utils.timezone import now, timedelta
from coin.models import CurrencyExchange, CoinType
from django.utils.translation import gettext_lazy as _
from currency_converter.django_client import get_converter_from_settings

logger = logging.getLogger(__name__)


class NoCoinExchangeException(Exception):
    def __init__(self, *args, **kwargs):
        self.message = _("No coin exchange")
        super().__init__(self.message)


class OldExchangeException(Exception):
    def __init__(self, *args, **kwargs):
        self.message = _("Exchange data not updated in the past 24 hours")
        super().__init__(self.message)


class UnsupportedExchangeException(Exception):
    def __init__(self, *args, **kwargs):
        self.message = _("No exchange data for the given coin type")
        super().__init__(self.message)


def _convert(currency_from: CoinType, currency_to: CoinType, amount: float):
    if currency_from.code == currency_to.code:
        return amount

    last_currency_exchange = CurrencyExchange.objects.last()
    if not last_currency_exchange:
        raise NoCoinExchangeException()

    # More than 24 hours:
    if last_currency_exchange.created < now() - timedelta(days=1):
        raise OldExchangeException()

    data = dict(json.loads(last_currency_exchange.exchange_data))
    if not data or not currency_from.code in data.keys():
        raise UnsupportedExchangeException()

    currency_converter = get_converter_from_settings()
    currency_data = currency_converter.get_currency_data_from_json(
        {currency_from.code: data[currency_from.code]}
    )
    return currency_data.convert(currency_from.code, currency_to.code, amount)


def convert_or_fetch(currency_from: CoinType, currency_to: CoinType, amount: float):
    """
    Perform a conversion for two coins and an amount using an online
    converter. If the conversion has not been stored in db in
    the past 24 hours it will be fetched from the online converter
    """
    try:
        return round(_convert(currency_from, currency_to, amount), 2)
    except Exception as e:
        logger.warning(str(e))
        currency_converter = get_converter_from_settings()
        return round(
            currency_converter.make_conversion(
                currency_from.code, currency_to.code, amount
            ),
            2,
        )


def update_exchange_data():
    """
    Create a new CurrencyExchange for today
    """
    first_currency_exchange = CurrencyExchange.objects.first()
    currency_converter = get_converter_from_settings()
    # A coin exchange for today should be created if there is no coin exchange
    # or the newest one created has a date diferent compared to today
    if (
        not first_currency_exchange
        or first_currency_exchange.created.date() != now().date()
    ):
        CurrencyExchange.objects.create(
            exchange_data=json.dumps(dict(currency_converter.get_currency_data().data))
        )

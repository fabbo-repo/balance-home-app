import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

CURRENCY_CONVERTER_URL = "https://www.xe.com/currencyconverter/convert/"


class ConnectionException(Exception):
    def __init__(self, *args, **kwargs):
        self.message = 'Currency converter connection error'
        super().__init__(self.message)


class HtmlParserException(Exception):
    def __init__(self, *args, **kwargs):
        self.message = 'Html parser no longer valid'
        super().__init__(self.message)


class CurrencyData:
    def __init__(self, data):
        """Data is a dict with the currency conversions"""
        self.data = data

    def convert(self, currency_from, currency_to, amount: float):
        if currency_from == currency_to:
            return amount
        return float(self.data[currency_from][currency_to]) * amount


class CurrencyConverterService:
    def __init__(self, currency_codes):
        self.currency_codes = currency_codes

    def make_conversions(self, reference_currency_code, ammount=1):
        res = {
            reference_currency_code: ammount
        }
        for code in self.currency_codes:
            # Ignore reference_currency_code
            if code == reference_currency_code:
                continue
            res[code] = self.make_conversion(
                reference_currency_code, code, ammount)
        return res

    def make_conversion(self, code_from, code_to, ammount=1):
        params = {}
        params["Amount"] = ammount
        params["From"] = code_from
        params["To"] = code_to
        resp = requests.get(CURRENCY_CONVERTER_URL, params=params)
        try:
            resp.raise_for_status()
        except:
            logger.error(
                '[CURRENCY CONVERTER] currency converter connection error')
            raise ConnectionError()
        html = resp.content
        return self._filter_html_response(html)

    def _filter_html_response(self, html):
        soup = BeautifulSoup(html, 'html.parser')
        try:
            return float(soup.body.find_all('p')[3].text.split(' ')[3])
        except:
            logger.error('[CURRENCY CONVERTER] html parser no longer valid')
            raise Exception('html parser no longer valid')

    def get_currency_data(self):
        logger.info("[CURRENCY CONVERTER] Fetching currency data")
        res = {}
        for code in self.currency_codes:
            data = self.make_conversions(code)
            data.pop(code)
            res[code] = data
        return CurrencyData(res)

    def get_currency_data_from_json(self, data):
        return CurrencyData(data)

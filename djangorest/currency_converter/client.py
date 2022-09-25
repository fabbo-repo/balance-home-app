import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

CURRENCY_CONVERTER_URL = "https://www.xe.com/currencyconverter/convert/"


class CurrencyData:

    def __init__(self, data):
        """Data is a dict with the currency conversions"""
        self.data = data

    def convert(self, currency_to, currency_from, ammount):
        return self.data[currency_to][currency_from] * ammount


class CurrencyConverterClient:
    def __init__(self, currency_codes):
        self.currency_codes = currency_codes

    def make_request(self, reference_currency_code, ammount=1):
        res = {
            reference_currency_code : ammount
        }
        for code in self.currency_codes:
            # Ignore reference_currency_code
            if code == reference_currency_code: continue
            params = {}
            params["Amount"] = ammount
            params["From"] = reference_currency_code
            params["To"] = code
            resp = requests.get(CURRENCY_CONVERTER_URL, params=params)
            try: resp.raise_for_status()
            except: 
                logger.error('[CURRENCY CONVERTER] currency converter connection error')
                raise Exception('currency converter connection error')
            html = resp.content
            res[code] = self._filter_html_response(html)
        return res
    
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
            data = self.make_request(code)
            data.pop(code)
            res[code] = data

        return CurrencyData(res)
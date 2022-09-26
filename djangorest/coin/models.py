from django.db import models
from django.utils.translation import gettext_lazy as _


class CoinType(models.Model):
    code = models.CharField(
        verbose_name = _('code'),
        max_length = 4, 
        primary_key = True
    )
    # Json for exchange data parsed to string
    # To save it:
    # coinX.exchange = json.dumps(data)
    # To retrive it:
    # json.loads(coinX.exchange)
    # Note: Every key and value would have type str
    exchange = models.TextField(
        verbose_name = _('exhange data dictionary'),
        default = '{}'
    )

    class Meta:
        verbose_name = _('Coin type')
        verbose_name_plural = _('Coin types')
        # Lower to greater exchange
        ordering = ['code']
    
    def __str__(self) -> str:
        return self.code
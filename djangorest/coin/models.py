from django.db import models
from django.utils.translation import gettext_lazy as _


class CoinType(models.Model):
    code = models.CharField(
        verbose_name = _('code'),
        max_length = 4, 
        primary_key = True
    )
    name = models.CharField(
        verbose_name = _('name'),
        max_length = 15, 
        unique = True
    )
    # Exchange compared to USD
    exchange = models.FloatField(
        verbose_name = _('exhange to USD'),
        default = 1.0
    )

    class Meta:
        verbose_name = _('Coin type')
        verbose_name_plural = _('Coin types')
        # Lower to greater exchange
        ordering = ['exchange']
    
    def __str__(self) -> str:
        return self.name
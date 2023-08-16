import uuid
from django.db import models
from django.utils.translation import gettext_lazy as _


class CoinType(models.Model):
    code = models.CharField(
        verbose_name = _("code"),
        max_length = 4, 
        primary_key = True
    )

    class Meta:
        verbose_name = _("Coin type")
        verbose_name_plural = _("Coin types")
        ordering = ["code"]
    
    def __str__(self) -> str:
        return self.code


class CurrencyExchange(models.Model):
    id = models.UUIDField(
        verbose_name = _("uuid"),
        primary_key = True, 
        default = uuid.uuid4,
        editable = False
    )
    # Json for exchange data parsed to string
    # To save it:
    # coinX.exchange_data = json.dumps(data)
    # To retrive it:
    # json.loads(coinX.exchange_data)
    # Note: Every key and value would have type str
    exchange_data = models.TextField(
        verbose_name = _("data exhange dictionary"),
        default = "{}"
    )
    created = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _("Coin exchange")
        verbose_name_plural = _("Coin exchanges")
        # Greater to lower date
        ordering = ["-created"]
    
    def __str__(self) -> str:
        return str(self.created)
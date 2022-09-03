from django.db import models
from custom_auth.models import User
from django.core.validators import MinValueValidator


class CoinType(models.Model):
    name = models.CharField(max_length=15, unique=True)
    simb = models.CharField(max_length=4, unique=True)

    class Meta:
        verbose_name = 'CoinType'
        verbose_name_plural = 'CoinTypes'
    
    def __str__(self) -> str:
        return self.name


class Balance(models.Model):
    id = models.BigAutoField(
        primary_key=True,
        editable=False
    )
    name = models.CharField(max_length=40)
    description = models.CharField(
        max_length=2000, 
        default=""
    )
    quantity = models.FloatField(
        validators=[MinValueValidator(0.0)],
    )
    date = models.DateField()
    coin_type = models.ForeignKey(
        CoinType, 
        on_delete=models.DO_NOTHING
    )
    owner = models.ForeignKey(
        User, 
        on_delete=models.CASCADE
    )
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Balance'
        verbose_name_plural = 'Balances'
        abstract = True
    
    def __str__(self) -> str:
        return str(self.name)
import uuid
from django.db import models
from custom_auth.models import User
from django.core.validators import MaxValueValidator, MinValueValidator
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

    class Meta:
        verbose_name = _('Coin type')
        verbose_name_plural = _('Coin types')
    
    def __str__(self) -> str:
        return self.name


class Balance(models.Model):
    id = models.BigAutoField(
        primary_key = True,
        editable = False
    )
    name = models.CharField(
        verbose_name = _('name'),
        max_length = 40
    )
    description = models.CharField(
        verbose_name = _('description'),
        max_length = 2000, 
        default = ""
    )
    quantity = models.FloatField(
        verbose_name = _('quantity'),
        validators = [MinValueValidator(0.0)],
    )
    date = models.DateField(
        verbose_name = _('date')
    )
    coin_type = models.ForeignKey(
        CoinType, 
        verbose_name = _('coin type'),
        on_delete = models.DO_NOTHING
    )
    owner = models.ForeignKey(
        User, 
        verbose_name = _('owner'),
        on_delete = models.CASCADE
    )
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _('Balance')
        verbose_name_plural = _('Balances')
        abstract = True
        ordering = ['-date']
    
    def __str__(self) -> str:
        return str(self.name)


class DateBalance(models.Model):
    id = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4, 
        editable=False
    )
    # All revenues and expenses
    gross_quantity = models.FloatField(
        verbose_name = _('gross quantity')
    )
    # expected_quantity - gross_quantity
    net_quantity = models.FloatField(
        verbose_name = _('net quantity')
    )
    coin_type = models.ForeignKey(
        CoinType,
        verbose_name = _('coin type'),
        on_delete=models.DO_NOTHING
    )
    owner = models.ForeignKey(
        User,
        verbose_name = _('owner'),
        on_delete=models.CASCADE
    )
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _('Date balance')
        verbose_name_plural = _('Date balances')
        abstract = True
        ordering = ['-created']
    
    def __str__(self) -> str:
        return str(self.created)

class AnnualBalance(DateBalance):
    year = models.PositiveIntegerField(
        verbose_name = _('year'),
        validators=[
            MinValueValidator(1),
            MaxValueValidator(5000),
        ]
    )

    class Meta:
        verbose_name = _('Annual balance')
        verbose_name_plural = _('Annual balances')
    
    def __str__(self) -> str:
        return str(self.year)

class MonthlyBalance(AnnualBalance):
    month = models.PositiveIntegerField(
        verbose_name = _('month'),
        validators=[
            MinValueValidator(1),
            MaxValueValidator(12),
        ]
    )

    class Meta:
        verbose_name = _('Monthly balance')
        verbose_name_plural = _('Monthly balances')
    
    def __str__(self) -> str:
        return str(self.month)+' - '+str(self.year)
import uuid
from django.db import models
from custom_auth.models import User
from django.core.validators import MaxValueValidator, MinValueValidator


class CoinType(models.Model):
    simb = models.CharField(max_length=4, primary_key=True)
    name = models.CharField(max_length=15, unique=True)

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
        ordering = ['-date']
    
    def __str__(self) -> str:
        return str(self.name)


class DateBalance(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    quantity = models.FloatField(
        validators=[MinValueValidator(0.0)],
    )
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
        verbose_name = 'Date Balance'
        verbose_name_plural = 'Date Balances'
        abstract = True
        ordering = ['-created']
    
    def __str__(self) -> str:
        return str(self.created)

class AnnualBalance(DateBalance):
    year = models.PositiveIntegerField(
        validators=[
            MinValueValidator(1),
            MaxValueValidator(5000),
        ]
    )

    class Meta:
        verbose_name = 'Annual Balance'
        verbose_name_plural = 'Annual Balances'
    
    def __str__(self) -> str:
        return str(self.year)

class MonthlyBalance(AnnualBalance):
    month = models.PositiveIntegerField(
        validators=[
            MinValueValidator(1),
            MaxValueValidator(12),
        ]
    )

    class Meta:
        verbose_name = 'Monthly Balance'
        verbose_name_plural = 'Monthly Balances'
    
    def __str__(self) -> str:
        return str(self.month)+' - '+str(self.year)